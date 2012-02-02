package mikedotalmond.napoleon.examples.binaryclock {
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	import flash.events.Event;
	
	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	
	import mikedotalmond.napoleon.forces.PointField;
	import mikedotalmond.napoleon.NapePolygon2D;
	import mikedotalmond.napoleon.NapeQuad2D;
	import mikedotalmond.napoleon.NapeScene2D;
	
	import nape.geom.Vec2;
	import nape.phys.BodyType;
	import nape.phys.Material;
	
	public final class BinaryClockScene extends NapeScene2D {
		
		public static const Logger						:ILogger								= Logging.getLogger(BinaryClockScene);	
		
		private static const HalfPi						:Number								= Math.PI / 2;
		private static const TwoPi						:Number 								= Math.PI * 2;
		private static const FourPi						:Number 								= Math.PI * 4;
		private static const clockHueRange			:Vector.<uint>		 				= ClockUtil.getHueRange(ClockUtil.hsl(0xff0000), 60); // range of hues from 0xff0000 and back, over 60 steps
		private static	const clockQuadRadii		:Vector.<Number> 				= Vector.<Number>([-248, -296, -344, -382, -414, -441]);
		private static const clockQuadSizes		:Vector.<Vector.<Number>>	= Vector.<Vector.<Number>>([
			Vector.<Number>([1, 1]),
			Vector.<Number>([1 / 2, 1]),
			Vector.<Number>([1 / 4, 1 / 1.125]),
			Vector.<Number>([1 / 8, 1 / 1.25]),
			Vector.<Number>([1 / 16, 1 / 1.5]),
			Vector.<Number>([1 / 32, 1 / 2])
		]);
		
		private const tempV			:Vec2 = new Vec2();
		
		private var quads				:Vector.<Vector.<NapeQuad2D>>;
		private var edgeField			:PointField;
		private var pointField			:PointField;
		private var count					:Number = 0;	
		
		public function BinaryClockScene() {
			preferredAntialiasing = 6; // edges need a bit of AA love...
			super();
			Logger.info("Testing some kinematic animation, and point force-fields. Uses the clock layout from a previous experiment (see: github.com/mikedotalmond/labs/binaryClock)");
			Logger.info("Use the mouse-wheel to zoom in/out");
		}
		
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			mouseWheelZoom = true;
			camera.zoom = 0.78; // zoom out a little
			
			createBitsQuads();
			setupFields();
		}
		
		private function setupFields():void {
			
			pointField 	= new PointField(new Vec2(), null, NaN, 12, 20);
			edgeField 	= new PointField(new Vec2(), null, 256, -32, 20);
			
			var c			:uint
			var rand		:Number
			var circle	:NapePolygon2D;
			var n			:int = 512;
			
			while (--n) {
				rand 		= Math.random();
				c			= (rand >= 0.6666) ? 0xff800000 : ((rand >= 0.3333) ? 0xff008000 : 0xff000080);
				circle 	= new NapePolygon2D(NapePolygon2D.regularPolygon((2 + Math.random() ), 8), null, c);
				circle.init(getRandomStagePosition(), true, null, Material.sand());
				circle.body.scaleShapes(3, 3);
				circle.body.allowRotation = false;
				pointField.addBody(circle.body);
				edgeField.addBody(circle.body);
				addChild(circle);
			}
		}
		
		/**
		 * 
		 */
		private function createBitsQuads():void {
			
			quads 	= new Vector.<Vector.<NapeQuad2D>>(59, true);
			
			const pad				:int 			= 48;
			const size				:Number 	= 32;
			var   n					:int 			= 59;
			
			var nextY				:int 			= 0;
			var  i						:int 			= -1;
			var j						:int 			= -1; 
			const m				:int			= clockQuadSizes.length;
			
			const  w				:uint 			= _width >> 1;
			const  h				:uint 			= _height >> 1;
			var angle				:Number 	= 0;
			var angleIncrement	:Number 	=TwoPi / 60;
			const bodyRotation:Number 	= -HalfPi;
			
			var lastColour		:uint;
			var nextColour		:uint;
			
			while (++i < n) {
				
				quads[i] 		= new Vector.<NapeQuad2D>(m, true);
				// with last and next colours on left and right edges of the quad, we get a nice graduation, with the current colour in the middle
				lastColour		= (0xFF << 24)	| clockHueRange[int((i == 0) ? n - 1 : i - 1)];
				nextColour 	= (0xFF << 24)	| clockHueRange[int((i == n - 1) ? 0 : i + 1)];
				
				j = -1;
				while (++j < m) {
					if (i & (1 << j)){ // only create bits where needed... running up 1,2,4,8,16,32
						quads[i][j] 							= new NapeQuad2D(size * clockQuadSizes[j][0], size * clockQuadSizes[j][1]);
						quads[i][j].topLeftColor 	 	= quads[i][j].bottomLeftColor	= lastColour;
						quads[i][j].topRightColor 	= quads[i][j].bottomRightColor	= nextColour;
						quads[i][j].init(tempV,  null, BodyType.KINEMATIC);
						addChild(quads[i][j]);
					}
				}
			}
			positionBits(0);
		}
		
		/**
		 * 
		 * @param	value		0 to 59 value (seconds) to rotate the clock face....
		 */
		private function positionBits(value:Number):void {
			
			const bodyRotation:Number 	= -HalfPi
			var bits					:Vector.<NapeQuad2D>;
			var n						:int 			= quads.length;
			var m					:int 			= clockQuadRadii.length;
			var i						:int			= -1;
			var j						:int;
			var a						:Number;
			var angle				:Number 	= bodyRotation + TwoPi * (value / (n + 1));
			var angleIncrement	:Number 	=TwoPi / (n + 1);
			
			while (++i < n) {
				a			= angle + bodyRotation;
				j 			= -1;
				bits 		= quads[i];
				
				while (++j < m) {
					if (i & (1 << j)) {
						bits[j].body.position.set(getBitPosition(angle, clockQuadRadii[j]));
						bits[j].body.rotation = a;
					}
				}
				
				angle += angleIncrement;
			}
		}
		
		/**
		 * Get a position from the centre of the visible stage, at radius, swept through angle
		 * @param	angle
		 * @param	radius
		 * @return
		 */
		private function getBitPosition(angle:Number, radius:Number):Vec2 {
			tempV.setxy((_width >> 1) + radius * Math.cos(angle),  (_height >> 1) + radius * Math.sin(angle));
			return tempV;
		}
		
		/**
		 * 
		 * @param	elapsed
		 */
		override protected function step(elapsed:Number):void {
			
			edgeField.position.set(getBitPosition(Math.cos(FourPi * (count / 45)), Math.cos(TwoPi* (count / 88)) * 256));
			pointField.position.set(getBitPosition(TwoPi * (count / 30), 32));
			
			edgeField.update();
			pointField.update();
			
			positionBits(count);
			count -= 0.14;
			
			super.step(elapsed);
		}
		
		override public function dispose():void {
			pointField.dispose();
			pointField = null;
			edgeField.dispose();
			edgeField = null;
			quads = null;
			super.dispose();
		}
	}
}