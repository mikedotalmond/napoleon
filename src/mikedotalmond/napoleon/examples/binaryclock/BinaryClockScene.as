/*
Copyright (c) 2012 Mike Almond - @mikedotalmond - https://github.com/mikedotalmond

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/


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
		
		public static const Logger				:ILogger					= Logging.getLogger(BinaryClockScene);	
		
		private static const HalfPi				:Number						= Math.PI / 2;
		private static const TwoPi				:Number 					= Math.PI * 2;
		private static const FourPi				:Number 					= Math.PI * 4;
		private static const clockHueRange		:Vector.<uint>		 		= ClockUtil.getHueRange(ClockUtil.hsl(0xff0000), 60); // range of hues from 0xff0000 and back, over 60 steps
		private static const clockQuadRadii		:Vector.<Number> 			= Vector.<Number>([-248, -296, -344, -382, -414, -441]);
		private static const clockQuadSizes		:Vector.<Vector.<Number>>	= Vector.<Vector.<Number>>([
			Vector.<Number>([1, 1]),
			Vector.<Number>([1 / 2, 1]),
			Vector.<Number>([1 / 4, 1 / 1.125]),
			Vector.<Number>([1 / 8, 1 / 1.25]),
			Vector.<Number>([1 / 16, 1 / 1.5]),
			Vector.<Number>([1 / 32, 1 / 2])
		]);
		
		private const tempV				:Vec2 = new Vec2();
		
		private var quads				:Vector.<Vector.<NapeQuad2D>>;
		private var edgeField			:PointField;
		private var pointField			:PointField;
		
		private var bitsPositionIndex	:uint = 0;	
		private var quadPositions		:Vector.<Vector.<Vector.<Vec2>>>;
		private var quadRotations		:Vector.<Vector.<Vector.<Number>>>;
		private var cacheSize			:uint;
		
		
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
			velocityIterations = positionIterations = 1;
			createBitsQuads();
			setupFields();
			cacheSize = 1080;
			cacheQuadPositions();
		}
		
		private function setupFields():void {
			
			pointField 	= new PointField(new Vec2(), null, NaN, 12, 20);
			edgeField 	= new PointField(new Vec2(), null, 256, -32, 20);
			
			var c		:uint
			var rand	:Number
			var circle	:NapePolygon2D;
			var n		:int = 512;
			
			while (--n) {
				rand 	= Math.random();
				c		= (rand >= 0.66666) ? 0xff800000 : ((rand >= 0.33333) ? 0xff008000 : 0xff000080); // random choice of R,G,or B
				circle 	= new NapePolygon2D(NapePolygon2D.regularPolygon((1.5 + Math.random() ), 8), null, c);
				circle.init(getRandomStagePosition(), true, null, Material.sand());
				circle.body.scaleShapes(3, 3); // make the physics shape bigger than the nd2d display
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
			
			const size			:Number = 32;
			const m				:int	= clockQuadSizes.length;
			var   n				:int 	= 59;
			var i				:int 	= -1;
			var j				:int 	= -1;
			var lastColour		:uint;
			var nextColour		:uint;
			
			while (++i < n) {
				
				quads[i] 		= new Vector.<NapeQuad2D>(m, true);
				// with last and next colours on left and right edges of the quad, we get a nice graduation, with the current colour in the middle
				lastColour	= (0xFF << 24)	| clockHueRange[int((i == 0) ? n - 1 : i - 1)];
				nextColour 	= (0xFF << 24)	| clockHueRange[int((i == n - 1) ? 0 : i + 1)];
				
				j = -1;
				while (++j < m) {
					if (i & (1 << j)){ // only create bits where needed... running up 1,2,4,8,16,32
						quads[i][j] = new NapeQuad2D(size * clockQuadSizes[j][0], size * clockQuadSizes[j][1]);
						quads[i][j].topLeftColor	= quads[i][j].bottomLeftColor	= lastColour;
						quads[i][j].topRightColor	= quads[i][j].bottomRightColor	= nextColour;
						quads[i][j].init(tempV,  null, BodyType.KINEMATIC);
						addChild(quads[i][j]);
					}
				}
			}
		}
		
		
		private function positionBits():void {
			
			const p	:Vector.<Vector.<Vec2>>		= quadPositions[bitsPositionIndex];
			const r	:Vector.<Vector.<Number>>	= quadRotations[bitsPositionIndex];
			
			var bits:Vector.<NapeQuad2D>;
			var n	:int = quads.length;
			var m	:int = clockQuadRadii.length;
			var i	:int = -1;
			var j	:int;
			
			while (++i < n) {
				j		= -1;
				bits 	= quads[i];
				while (++j < m) {
					if (i & (1 << j)) {
						bits[j].body.position.set(p[i][j]);
						bits[j].body.rotation = r[i][j];
					}
				}
			}
		}
		
		
		
		private function cacheQuadPositions():void {
		
			const sz:uint 	= cacheSize;
			quadPositions	= new Vector.<Vector.<Vector.<Vec2>>>(sz, true);
			quadRotations 	= new Vector.<Vector.<Vector.<Number>>>(sz, true);
			
			const stepSize			:Number = TwoPi / sz; // rotate 360 degress over the step range
			const bodyRotation		:Number = -HalfPi; // offset rotation so quads point outwards
			const n					:int 	= quads.length;
			const m					:int 	= clockQuadRadii.length;
			const angleIncrement	:Number = TwoPi / (n + 1);
			
			var i					:int;
			var j					:int;
			var k					:int;
			var bodyAngle			:Number;
			var angle				:Number;
			
			k = -1;
			while (++k < sz) { // for each step of movement
				quadPositions[k] 	= new Vector.<Vector.<Vec2>>(n, true);
				quadRotations[k] 	= new Vector.<Vector.<Number>>(n, true);
				angle 				= bodyRotation + (k * stepSize);
				i 					= -1;
				while (++i < n) { // for each quad
					quadPositions[k][i]	= new Vector.<Vec2>(m, true);
					quadRotations[k][i]	= new Vector.<Number>(m, true);
					bodyAngle			= angle + bodyRotation;
					j 					= -1;
					while (++j < m) {
						if (i & (1 << j)) { // for each active bit, store position and rotation
							quadPositions[k][i][j] = getBitPosition(angle, clockQuadRadii[j]).copy(); 
							quadRotations[k][i][j] = bodyAngle;
						}
					}
					angle += angleIncrement;
				}
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
			
			edgeField.position.set(getBitPosition(Math.cos(FourPi * (bitsPositionIndex / 450)), Math.cos(TwoPi* (bitsPositionIndex / 888)) * 256));
			pointField.position.set(getBitPosition(TwoPi * (bitsPositionIndex / 300), 32));
			
			edgeField.update();
			pointField.update();
			
			positionBits();
			if (bitsPositionIndex == 0) bitsPositionIndex = quadPositions.length;
			bitsPositionIndex--;
			
			super.step(elapsed);
		}
		
		override public function resize(w:uint, h:uint):void {
			super.resize(w, h);
			if(quads) cacheQuadPositions();
		}
		
		override public function dispose():void {
			quadPositions = null;
			quadRotations = null;
			pointField.dispose();
			pointField = null;
			edgeField.dispose();
			edgeField = null;
			quads = null;
			super.dispose();
		}
	}
}