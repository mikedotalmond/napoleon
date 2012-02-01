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
		
		static public const Logger	:ILogger	= Logging.getLogger(BinaryClockScene);		
		
		private var quads				:Vector.<Vector.<NapeQuad2D>>;
		private var edgeField			:PointField;
		private var pointField			:PointField;
		
		private const pihalf				:Number = Math.PI / 2;
		private const pi2				:Number = Math.PI * 2;
		private const pi4				:Number = pi2 + pi2;
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
			camera.zoom = 0.78;
			createBitsQuads();
		}
		
		private function createBitsQuads():void {
			
			quads 	= new Vector.<Vector.<NapeQuad2D>>(59, true);
			
			const pad				:int 			= 48;
			const size				:Number 	= 32;
			var   n					:int 			= 59;
			
			var nextY				:int 			= 0;
			var  i						:int 			= -1;
			var bit					:NapeQuad2D;
			
			const  w				:uint 			= _width >> 1;
			const  h				:uint 			= _height >> 1;
			var angle				:Number 	= 0;
			var angleIncrement	:Number 	=pi2 / 60;
			const bodyRotation:Number 	= -pihalf;
			
			const hueRange	:Vector.<uint> = ClockUtil.getHueRange(ClockUtil.hsl(0xff0000), 60);
			var lastColour		:uint;
			var nextColour		:uint;
			
			while (++i < n) {
				
				quads[i] 		= new Vector.<NapeQuad2D>(6, true);
				// with last and next colours on left and right edges of the quad, we get a nice graduation, with the current colour in the middle
				lastColour		= (0xFF << 24)	| hueRange[int((i == 0) ? n - 1 : i - 1)];
				nextColour 	= (0xFF << 24)	| hueRange[int((i == n - 1) ? 0 : i + 1)];
				nextY 			= -248;
				
				if (i & 0x01) { //1
					bit 			= new NapeQuad2D(size, size);
					bit.init		(tempV,  null, BodyType.KINEMATIC);
					bit.topLeftColor = bit.bottomLeftColor 		= lastColour;
					bit.topRightColor = bit.bottomRightColor 	= nextColour;
					quads[i][0] = bit;
					addChild(bit);
				}
				nextY -= pad;
				if (i & 0x02) { //2
					bit			 = new NapeQuad2D(size / 2, size);
					bit.init		(tempV, null, BodyType.KINEMATIC);
					bit.topLeftColor = bit.bottomLeftColor 		=  lastColour;
					bit.topRightColor = bit.bottomRightColor 	=  nextColour;
					quads[i][1] = bit;
					addChild(bit);
				}
				nextY -= pad;
				if (i & 0x04) { //4
					bit 			= new NapeQuad2D(size / 4, size / 1.125);
					bit.init		(tempV, null, BodyType.KINEMATIC);
					bit.topLeftColor = bit.bottomLeftColor 		=  lastColour;
					bit.topRightColor = bit.bottomRightColor 	=  nextColour;
					quads[i][2] = bit;
					addChild(bit);
				}
				nextY -= pad/1.25;
				if (i & 0x08) { //8
					bit 			= new NapeQuad2D(size / 8, size / 1.25);
					bit.init		(tempV, null, BodyType.KINEMATIC);
					bit.topLeftColor = bit.bottomLeftColor 		=  lastColour;
					bit.topRightColor = bit.bottomRightColor 	=  nextColour;
					quads[i][3] = bit;
					addChild(bit);
				}
				nextY -= pad/1.5;
				if (i & 0x10) { //16
					bit 			= new NapeQuad2D(size / 16, size / 1.5);
					bit.init		(tempV, null, BodyType.KINEMATIC);
					bit.topLeftColor = bit.bottomLeftColor 		=  lastColour;
					bit.topRightColor = bit.bottomRightColor 	=  nextColour;
					bit.body.rotation = angle + bodyRotation;
					quads[i][4] = bit;
					addChild(bit);
				}
				nextY -= pad/1.75;
				if (i & 0x20) { //32
					bit 			= new NapeQuad2D(size / 32, size / 2);
					bit.init		(tempV, null, BodyType.KINEMATIC);
					bit.topLeftColor = bit.bottomLeftColor 		=  lastColour;
					bit.topRightColor = bit.bottomRightColor 	=  nextColour;
					quads[i][5] = bit;
					addChild(bit);
				}	
			}
			
			positionBits(quads, 0);
			
			space.gravity = new Vec2(0, 0);
			pointField 		= new PointField(new Vec2(w, h), null, NaN, 12, 20);
			edgeField 		= new PointField(new Vec2(w, h), null, 256, -14, 20);
			
			var circle:NapePolygon2D;
			
			n = 512;
			while (--n) {
				var rand	:Number = Math.random();
				var c		:uint = (rand >= 0.6666) ? 0xff800000 : ((rand >= 0.3333) ? 0xff008000 : 0xff000080);
				circle = new NapePolygon2D(NapePolygon2D.regularPolygon((1 + Math.random() * 2), 8), null, c);
				circle.init(getRandomStagePosition(), true, null, Material.steel());
				circle.body.scaleShapes(3, 3);
				circle.body.allowRotation = false;
				//circle.body.group = g;
				pointField.addBody(circle.body);
				edgeField.addBody(circle.body);
				addChild(circle);
			}
			
		}
		
		override public function dispose():void {
			pointField.dispose();
			pointField = null;
			edgeField.dispose();
			edgeField = null;
			quads = null;
			super.dispose();
		}
		
		override protected function step(elapsed:Number):void {
			edgeField.position.set(getBitPosition(Math.cos(pi4 * (count / 45)), 80));
			pointField.position.set(getBitPosition(pi2 * (count / 30), 32));
			
			edgeField.update();
			pointField.update();
			
			positionBits(quads, count);
			super.step(elapsed);
			count -= 0.14;
		}
		
		private function positionBits(input:Vector.<Vector.<NapeQuad2D>>, value:Number):void {
			
			const bodyRotation:Number 	= -pihalf
			var bits					:Vector.<NapeQuad2D>;
			var n						:int 			= input.length;
			var i						:int			= -1;
			var a						:Number 	= 0;
			var angle				:Number 	= bodyRotation + pi2 * (value / (n + 1));
			var angleIncrement	:Number 	=pi2 / (n + 1);
			
			const pad		:int = 48;
			var nextY		:int
			
			while (++i < n) {
				a			= angle + bodyRotation;
				nextY 	= -248;
				bits 		= input[i];
				if (bits[0]) { //1
					bits[0].body.position.set(getBitPosition(angle, nextY));
					bits[0].body.rotation = a;
				}
				nextY -= pad;
				if (bits[1]) { //2
					bits[1].body.position.set(getBitPosition(angle, nextY));
					bits[1].body.rotation = a;
				}
				nextY -= pad;
				if (bits[2]) { //4
					bits[2].body.position.set(getBitPosition(angle, nextY));
					bits[2].body.rotation = a;
				}
				nextY -= pad/1.25;
				if (bits[3]) { //8
					bits[3].body.position.set(getBitPosition(angle, nextY));
					bits[3].body.rotation = a;
				}
				nextY -= pad/1.5;
				if (bits[4]) { //16
					bits[4].body.position.set(getBitPosition(angle, nextY));
					bits[4].body.rotation = a;
				}
				nextY -= pad/1.75;
				if (bits[5]) { //32
					bits[5].body.position.set(getBitPosition(angle, nextY));
					bits[5].body.rotation = a;
				}
				
				nextY -= pad;
				angle += angleIncrement;
			}
		}
		
		private const tempV:Vec2 = new Vec2();
		private function getBitPosition(angle:Number, radius:Number):Vec2 {
			tempV.setxy((_width >> 1) + radius * Math.cos(angle),  (_height >> 1) + radius * Math.sin(angle));
			return tempV; 
		}
	}
}