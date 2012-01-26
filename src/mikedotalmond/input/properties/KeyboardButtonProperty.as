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
package mikedotalmond.input.properties {
	

	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	import flash.geom.Point;
	import mikedotalmond.input.KeyboardPlus;
	import org.osflash.signals.Signal;
	
	public final class KeyboardButtonProperty implements IGameControllerProperty {
		
		private var _intensity	:Number = 0;
		private var _keyCode	:uint 	= 0;
		private var _update		:Signal;
		
		public function KeyboardButtonProperty(keyCode:uint, update:Signal) {
			_keyCode = keyCode;
			_update  = update;
			_update.add(this.update);
		}
		
		/* INTERFACE control.IGameControllerProperty */
		public function update():void {
			_intensity = KeyboardPlus.isDown(_keyCode) ? 1 : 0;
		}
		
		public function dispose():void {
			_update.remove(update);
			_update = null;
		}
		
		public function getIntensity():Number { return _intensity; }
		public function getDirection():Point { return null; }
		public function get isAnalog():Boolean { return false; }
		public function get isDirectional():Boolean { return false; }
		
	}
}