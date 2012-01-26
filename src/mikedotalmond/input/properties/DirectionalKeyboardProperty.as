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
package mikedotalmond.input.properties  {
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	import flash.geom.Point;
	import mikedotalmond.input.KeyboardPlus;
	import org.osflash.signals.Signal;
	
	public final class DirectionalKeyboardProperty implements IGameControllerProperty {
		
		private var _intensity	:Number = 0;
		private var _keyCodes	:Vector.<uint>;
		private var _direction	:Point = new Point();
		private var _update		:Signal;
		
		/**
		 * 
		 * @param	keyCodes	up,down,left,right
		 * @param	update
		 */
		public function DirectionalKeyboardProperty(keyCodes:Vector.<uint>, update:Signal) {
			_keyCodes = keyCodes;
			_keyCodes.fixed = true;
			_update = update;
			_update.add(this.update);
		}
		
		/* INTERFACE control.IGameControllerProperty */
		public function update():void {
			const u:Boolean = KeyboardPlus.isDown(_keyCodes[0]);
			const d:Boolean = KeyboardPlus.isDown(_keyCodes[1]);
			const l:Boolean = KeyboardPlus.isDown(_keyCodes[2]);
			const r:Boolean = KeyboardPlus.isDown(_keyCodes[3]);
			
			_intensity = (u || d || l || r) ? 1 : 0;
			_direction.y = u ? 1 : (d ? -1 : 0);
			_direction.x = r ? 1 : (l ? -1 : 0);			
		}
		
		public function dispose():void {
			_keyCodes = null;
			_direction 	= null;
			_update.remove(update);
			_update 	= null;
		}
		
		public function getIntensity():Number { return _intensity; }
		
		public function getDirection():Point { return _direction; }
		
		public function get isAnalog():Boolean { return false; }
		
		public function get isDirectional():Boolean { return true; }
	}
}