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
package  {
	
	import com.furusystems.dconsole2.DConsole;
	import mikedotalmond.napoleon.examples.LineTest;
	import mikedotalmond.napoleon.examples.QuadListScene;
	
	import flash.display.StageDisplayState;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import mikedotalmond.input.KeyboardGamepadController;
	import mikedotalmond.input.KeyboardPlus;
	import mikedotalmond.napoleon.examples.binaryclock.BinaryClockScene;
	import mikedotalmond.napoleon.examples.car.CarScene;
	import mikedotalmond.napoleon.examples.PointFieldTest;
	import mikedotalmond.napoleon.examples.PolygonTestScene;
	import mikedotalmond.napoleon.examples.TestScene2D;
	import mikedotalmond.napoleon.NapeWorld2D;
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	 public final class Main extends NapeWorld2D {
		
		public function Main() {
			super(Context3DRenderMode.AUTO, 60);
			GameControllerClass = KeyboardGamepadController;
		}
		
		override protected function addedToStage(event:Event):void {
			super.addedToStage(event);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			stage.doubleClickEnabled = true;
			stage.addEventListener(MouseEvent.DOUBLE_CLICK, toggleFullscreen, false, 0, true);
		}
		
		override protected function setupDConsole():void {
			super.setupDConsole();
			Logger.info("When not using the console, you can skip  through the test scenes using 'n' (next) and 'p' (previous) ... and go full-screen using 'f'");
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			if (e.target is TextField) return;
			
			if (e.keyCode == KeyboardPlus.N) { // next scene...
				e.preventDefault();
				nextScene();
			} else if (e.keyCode == KeyboardPlus.P) {
				e.preventDefault();
				nextScene(-1);
			} else if (e.keyCode == KeyboardPlus.F) {
				if (stage) {
					try {
						stage.displayState = StageDisplayState.FULL_SCREEN;
						DConsole.hide();
					} catch (err:Error) {
						Logger.error(err); //allowFullscreen not set?
					}
				}
			}
		}
		
		override protected function setupScenes():void {
			addScene(BinaryClockScene, "clock");
			addScene(TestScene2D, "boxes");
			addScene(PolygonTestScene, "poly");
			addScene(CarScene, "car");
			addScene(PointFieldTest, "gravity");
			addScene(LineTest, "lines");
			//addScene(QuadListScene, "quad");
		}
		
		override protected function context3DCreated(e:Event):void {
			super.context3DCreated(e);
			nextScene(); //select the first scene
		}
	}
}