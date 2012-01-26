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
package mikedotalmond.napoleon.examples.carScene {
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.ColorUtil;
	import de.nulldesign.nd2d.utils.NumberUtil;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import nape.geom.Vec2;
	
	/**
	 * Tyre smoke using Sprite2DCloud
	 * Mouse x/y controls a 'wind' on the particles
	 */
	public final class TyreSmoke extends Node2D {
		
		[Embed(source="../../../../../assets/smoke32.png")]
		private static const SmokeDecal:Class;
		
		private var particlesPerSecond	:Number = 512;
		
		private var weightsTotal	:Number;
		public var spriteCloud		:Sprite2DCloud;
		public var smokeWeights		:Vector.<Number>;
		public var smokePositions	:Vector.<Point>;
		public var smokeVelocities	:Vector.<Point>;
		public var wind				:Point = new Point();
		public var active			:Boolean=false;
		
		public function TyreSmoke(numWheels:uint) {
			super();
			init(numWheels);
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }
		
		override public function dispose():void {
			spriteCloud = null;
			smokeWeights = null;
			smokePositions = null;
			smokeVelocities = null;
			super.dispose();
		}
		
		private function init(numWheels:uint):void {
			
			smokeWeights	= new Vector.<Number>(numWheels,true);
			smokePositions 	= new Vector.<Point>(numWheels,true);
			smokeVelocities	= new Vector.<Point>(numWheels, true);
			
			var i:int = numWheels;
			while (--i > -1) {
				smokeWeights[i] 	= 0;
				smokePositions[i] 	= new Point();
				smokeVelocities[i] 	= new Point();
			}
			
			smokeWeights.fixed = smokePositions.fixed = smokeVelocities.fixed = true;
		}
		
        protected function addedToStage(e:Event):void {
			
            removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
            var maxParticles:uint = smokePositions.length * 320;
            var s			:Sprite2D;
			
			particlesPerSecond 		= maxParticles >> 1;
			
            spriteCloud 			= new Sprite2DCloud(maxParticles, Texture2D.textureFromBitmapData(new SmokeDecal().bitmapData));
            spriteCloud.blendMode 	= BlendModePresets.ADD_PREMULTIPLIED_ALPHA;
			
            for(var i:int = 0; i < maxParticles; i++) {
                s = new Sprite2D();
				s.mouseEnabled = false;
				s.alpha = 0;
				s.visible = false;
                spriteCloud.addChild(s);
            }
			
            addChild(spriteCloud);
        }

        override protected function step(elapsed:Number):void {
			// testing wind (not the most efficient way of updating the wind though...)
            wind.x = (((stage.mouseX - (stage.stageWidth / 2)) / (stage.stageWidth / 2)))*9.8;
            wind.y = (((stage.mouseY - (stage.stageHeight / 2)) / (stage.stageHeight / 2)))*9.8;
			
			var n:uint = smokeWeights.length;
			var i:int  = n;
			
			var maxReset:uint = uint(elapsed * particlesPerSecond);
			var resetCount:uint = 0;
			weightsTotal = 0; // accumulate weights
			while(--i > -1) weightsTotal += smokeWeights[i];
			
			for each (var child:Node2D in spriteCloud.children) {
                if (child.alpha <= 0.0001 ){ // hide
					if(active && ++resetCount<maxReset) { // reset
						i = randomIndexFromWeights();
						if (i != -1) {
							child.visible = true;
							child.alpha = 0.07;
							child.x = smokePositions[i].x + (Math.random() -0.5) * 8;
							child.y = smokePositions[i].y + (Math.random() -0.5) * 4;
							child.vx = smokeVelocities[i].x + (Math.random() -0.5) + wind.x;
							child.vy = smokeVelocities[i].y + (Math.random() - 0.5) + wind.y;
							child.rotation = (Math.random() - 0.5) * 360;
							child.scaleX = child.scaleY = 1;
						} else {
							child.visible = false;
						}
					} else {
						child.visible = false;
					}
                } else if(child.visible){
					child.alpha 	-= 0.0008;
					child.x 		+= (child.vx *= 0.985);
					child.y 		+= (child.vy *= 0.985);
					child.scaleX 	+= Math.random() * 0.03;
					child.scaleY 	= child.scaleX;
				}                
            }		
        }
		
		private function randomIndexFromWeights() : int {
			
			if (weightsTotal <= 0) return -1;
			
			// pick a random number in the total range
			var rand:Number = Math.random() * weightsTotal;
			// step through array to find where that would be 
			var t:Number = weightsTotal;
			var i:int = smokeWeights.length;
			while ( --i > -1) {
				t -= smokeWeights[i];
				if( rand > t ) return i;
			}
			
			return -1;
		}
	}
}