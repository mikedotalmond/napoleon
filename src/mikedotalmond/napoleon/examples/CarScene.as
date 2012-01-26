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
package mikedotalmond.napoleon.examples {
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 * 
	 * Ported (loosely... with a fair bit of reworking) from a previous top-down car experiment
	 * See: https://github.com/mikedotalmond/labs/tree/master/topDown
	 * 
	 */
	
	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import mikedotalmond.napoleon.examples.carScene.Car;
	import mikedotalmond.napoleon.NapeScene2D;
	
	public final class CarScene extends NapeScene2D {
		
		static public const Logger	:ILogger = Logging.getLogger(CarScene);		
		
		private var _car			:Car;
		
		public function CarScene() {
			super();
			Logger.info("Top-down car test using Nape for the driving simulation, Sprite2DCloud for the smoke, and a QuadList for the skidmarks.");
			Logger.info("Left, Right, Up, Down to drive, space-bar for handbreak. Mouse position controls 'wind' direction and speed.");
		}
		
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			_car = new Car(this);
			backgroundColor = 0x606060;
		}		
		
		override public function onControllerUpdate():void {
			var a:Point = gameController.primaryDirection.getDirection();
			_car.steeringInput 		= a.x;
			_car.accelerationInput 	= a.y;
			_car.handbreakInput 	= gameController.buttonA.getIntensity() > 0;
		}
		
		override protected function step(elapsed:Number):void {
			_car.update();
			camera.x += ((_car.shell.position.x - stage.stageWidth / 2) - camera.x) * 0.075 * camera.zoom;
			camera.y += ((_car.shell.position.y - stage.stageHeight / 2) - camera.y) * 0.15 * camera.zoom;
			camera.zoom += ((1.1 - _car.absSpeed * 0.001) - camera.zoom) * 0.0025;
			super.step(elapsed);			
		}
		
		override public function dispose():void {
			_car.dispose();
			_car = null;
			super.dispose();
		}
	}
}