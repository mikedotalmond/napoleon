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
package mikedotalmond.input {
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	import mikedotalmond.input.IGameController;
	import mikedotalmond.input.KeyboardPlus;
	import mikedotalmond.input.properties.DirectionalKeyboardProperty;
	import mikedotalmond.input.properties.IGameControllerProperty;
	import mikedotalmond.input.properties.KeyboardButtonProperty;
	import org.osflash.signals.Signal;
	
	public final class KeyboardGamepadController implements IGameController {
		
		private var _update						:Signal;
		private var _buttonA					:IGameControllerProperty;
		private var _buttonB					:IGameControllerProperty;
		private var _buttonC					:IGameControllerProperty;
		private var _buttonD					:IGameControllerProperty;
		private var _primaryDirection		:IGameControllerProperty;
		private var _secondaryDirection	:IGameControllerProperty;
		
		public function KeyboardGamepadController(update:Signal) {
			_update			= update;
			_buttonA 			= new KeyboardButtonProperty(KeyboardPlus.SPACE, update);
			_buttonB 			= new KeyboardButtonProperty(KeyboardPlus.CONTROL, update);
			_buttonC 			= new KeyboardButtonProperty(KeyboardPlus.SHIFT, update);
			_buttonD 			= new KeyboardButtonProperty(KeyboardPlus.SLASH, update);
			_primaryDirection 	= new DirectionalKeyboardProperty(Vector.<uint>([KeyboardPlus.UP, KeyboardPlus.DOWN, KeyboardPlus.LEFT, KeyboardPlus.RIGHT]), update);
			_secondaryDirection = new DirectionalKeyboardProperty(Vector.<uint>([KeyboardPlus.W, KeyboardPlus.S, KeyboardPlus.A, KeyboardPlus.D]), update);
		}
		
		/* INTERFACE mikedotalmond.control.IGameController */
		public function get primaryDirection():IGameControllerProperty {
			return _primaryDirection;
		}
		
		public function get secondaryDirection():IGameControllerProperty {
			return _secondaryDirection;
		}
		
		public function get buttonA():IGameControllerProperty {
			return _buttonA;
		}
		
		public function get buttonB():IGameControllerProperty {
			return _buttonB;
		}
		
		public function get buttonC():IGameControllerProperty {
			return _buttonC;
		}
		
		public function get buttonD():IGameControllerProperty {
			return _buttonD;
		}
		
		public function get update():Signal {
			return _update;
		}
		
		public function dispose():void {
			_primaryDirection.dispose();
			_primaryDirection = null;
			_secondaryDirection.dispose();
			_secondaryDirection = null;
			_buttonA.dispose();
			_buttonA = null;
			_buttonB.dispose();
			_buttonB = null;
			_buttonC.dispose();
			_buttonC = null;
			_buttonD.dispose();
			_buttonD = null;
			_update = null;			
		}
	}
}