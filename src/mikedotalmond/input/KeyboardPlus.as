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
	
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	public final class KeyboardPlus {
		
		static public var INSTANCE			:KeyboardPlus = null;
		
		private static const ACTIVEKEYS	:Vector.<Boolean> = new Vector.<Boolean>(256,true);
		
		private var _stage							:Stage;
		
		public function KeyboardPlus(l:Lock) { };
		
		public static function get keyboardPlus():KeyboardPlus {
			if (INSTANCE == null) INSTANCE = new KeyboardPlus(new Lock());
			return INSTANCE;
		}
		
		public function init(stage:Stage):void {
			if (!_stage) {
				var n:int = ACTIVEKEYS.length;
				while (--n > -1) ACTIVEKEYS[n] = false;
				_stage = stage;
				_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, int.MAX_VALUE, true);
				_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, int.MAX_VALUE, true);
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void { ACTIVEKEYS[e.keyCode] = true; }
		private function onKeyUp(e:KeyboardEvent):void { ACTIVEKEYS[e.keyCode] = false; }
		public static function isDown(code:uint):Boolean { return ACTIVEKEYS[code]; }
		
		
		/** Constants and functions from flash.ui.Keyboard */
		
		/// Constant associated with the key code value for the Backspace key (8).
		public static const BACKSPACE : uint = 8;
		/// Constant associated with the key code value for the Caps Lock key (20).
		public static const CAPS_LOCK : uint = 20;
		/// Constant associated with the key code value for the Control key (17).
		public static const CONTROL : uint = 17;
		/// Constant associated with the key code value for the Delete key (46).
		public static const DELETE : uint = 46;
		/// Constant associated with the key code value for the Down Arrow key (40).
		public static const DOWN : uint = 40;
		/// Constant associated with the key code value for the End key (35).
		public static const END : uint = 35;
		/// Constant associated with the key code value for the Enter key (13).
		public static const ENTER : uint = 13;
		/// Constant associated with the key code value for the Escape key (27).
		public static const ESCAPE : uint = 27;
		/// Constant associated with the key code value for the F1 key (112).
		public static const F1 : uint = 112;
		/// Constant associated with the key code value for the F10 key (121).
		public static const F10 : uint = 121;
		/// Constant associated with the key code value for the F11 key (122).
		public static const F11 : uint = 122;
		/// Constant associated with the key code value for the F12 key (123).
		public static const F12 : uint = 123;
		/// Constant associated with the key code value for the F13 key (124).
		public static const F13 : uint = 124;
		/// Constant associated with the key code value for the F14 key (125).
		public static const F14 : uint = 125;
		/// Constant associated with the key code value for the F15 key (126).
		public static const F15 : uint = 126;
		/// Constant associated with the key code value for the F2 key (113).
		public static const F2 : uint = 113;
		/// Constant associated with the key code value for the F3 key (114).
		public static const F3 : uint = 114;
		/// Constant associated with the key code value for the F4 key (115).
		public static const F4 : uint = 115;
		/// Constant associated with the key code value for the F5 key (116).
		public static const F5 : uint = 116;
		/// Constant associated with the key code value for the F6 key (117).
		public static const F6 : uint = 117;
		/// Constant associated with the key code value for the F7 key (118).
		public static const F7 : uint = 118;
		/// Constant associated with the key code value for the F8 key (119).
		public static const F8 : uint = 119;
		/// Constant associated with the key code value for the F9 key (120).
		public static const F9 : uint = 120;
		/// Constant associated with the key code value for the Home key (36).
		public static const HOME : uint = 36;
		/// Constant associated with the key code value for the Insert key (45).
		public static const INSERT : uint = 45;
		/// Constant associated with the key code value for the Left Arrow key (37).
		public static const LEFT : uint = 37;
		/// Constant associated with the key code value for the number 0 key on the number pad (96).
		public static const NUMPAD_0 : uint = 96;
		/// Constant associated with the key code value for the number 1 key on the number pad (97).
		public static const NUMPAD_1 : uint = 97;
		/// Constant associated with the key code value for the number 2 key on the number pad (98).
		public static const NUMPAD_2 : uint = 98;
		/// Constant associated with the key code value for the number 3 key on the number pad (99).
		public static const NUMPAD_3 : uint = 99;
		/// Constant associated with the key code value for the number 4 key on the number pad (100).
		public static const NUMPAD_4 : uint = 100;
		/// Constant associated with the key code value for the number 5 key on the number pad (101).
		public static const NUMPAD_5 : uint = 101;
		/// Constant associated with the key code value for the number 6 key on the number pad (102).
		public static const NUMPAD_6 : uint = 102;
		/// Constant associated with the key code value for the number 7 key on the number pad (103).
		public static const NUMPAD_7 : uint = 103;
		/// Constant associated with the key code value for the number 8 key on the number pad (104).
		public static const NUMPAD_8 : uint = 104;
		/// Constant associated with the key code value for the number 9 key on the number pad (105).
		public static const NUMPAD_9 : uint = 105;
		/// Constant associated with the key code value for the addition key on the number pad (107).
		public static const NUMPAD_ADD : uint = 107;
		/// Constant associated with the key code value for the decimal key on the number pad (110).
		public static const NUMPAD_DECIMAL : uint = 110;
		/// Constant associated with the key code value for the division key on the number pad (111).
		public static const NUMPAD_DIVIDE : uint = 111;
		/// Constant associated with the key code value for the Enter key on the number pad (108).
		public static const NUMPAD_ENTER : uint = 108;
		/// Constant associated with the key code value for the multiplication key on the number pad (106).
		public static const NUMPAD_MULTIPLY : uint = 106;
		/// Constant associated with the key code value for the subtraction key on the number pad (109).
		public static const NUMPAD_SUBTRACT : uint = 109;
		/// Constant associated with the key code value for the Page Down key (34).
		public static const PAGE_DOWN : uint = 34;
		/// Constant associated with the key code value for the Page Up key (33).
		public static const PAGE_UP : uint = 33;
		/// Constant associated with the key code value for the Right Arrow key (39).
		public static const RIGHT : uint = 39;
		/// Constant associated with the key code value for the Shift key (16).
		public static const SHIFT : uint = 16;
		/// Constant associated with the key code value for the Spacebar (32).
		public static const SPACE : uint = 32;
		/// Constant associated with the key code value for the Tab key (9).
		public static const TAB : uint = 9;
		/// Constant associated with the key code value for the Up Arrow key (38).
		public static const UP : uint = 38;
		
		/// Specifies whether the Caps Lock key is activated (true) or not (false).
		public static function get capsLock () : Boolean { return Keyboard.capsLock; }
		/// Specifies whether the Num Lock key is activated (true) or not (false).
		public static function get numLock () : Boolean { return Keyboard.numLock; }
		
		/**
		 Specifies whether the last key pressed is accessible by other SWF files.
		 By default, security restrictions prevent code from a SWF file in one domain
		 from accessing a keystroke generated from a SWF file in another domain.
		 @return	The value true if the last key pressed can be accessed.
		 If access is not permitted, this method returns false.
		 */
		public static function isAccessible () : Boolean { return Keyboard.isAccessible(); }

		
		//---------------------------------------------------------------------------------------------------------------------------------------------
		// letters: 65-90 -----------------------------------------------------------------------------------------------------------------------------
		public static const A				:uint = 65;
		public static const B				:uint = 66;
		public static const C				:uint = 67;
		public static const D				:uint = 68;
		public static const E				:uint = 69;
		public static const F				:uint = 70;
		public static const G				:uint = 71;
		public static const H				:uint = 72;
		public static const I				:uint = 73;
		public static const J				:uint = 74;
		public static const K				:uint = 75;
		public static const L				:uint = 76;
		public static const M				:uint = 77;
		public static const N				:uint = 78;
		public static const O				:uint = 79;
		public static const P				:uint = 80;
		public static const Q				:uint = 81;
		public static const R				:uint = 82;
		public static const S				:uint = 83;
		public static const T				:uint = 84;
		public static const U				:uint = 85;
		public static const V				:uint = 86;
		public static const W				:uint = 87;
		public static const X				:uint = 88;
		public static const Y				:uint = 89;
		public static const Z				:uint = 90;
		//---------------------------------------------------------------------------------------------------------------------------------------------
		public static const ZERO		:uint = 48;
		public static const ONE			:uint = 49;
		public static const TWO 		:uint = 50;
		public static const THREE		:uint = 51;
		public static const FOUR		:uint = 52;
		public static const FIVE			:uint = 53;
		public static const SIX			:uint = 54;
		public static const SEVEN		:uint = 55;
		public static const EIGHT		:uint = 56;
		public static const NINE			:uint = 57;
		//---------------------------------------------------------------------------------------------------------------------------------------------
		public static const CLEAR			:uint = 12;
		public static const PAGEUP		:uint = 33;
		public static const PAGEDOWN	:uint = 34;
		public static const HELP			:uint = 47;
		public static const NUMLOCK	:uint = 144;
		public static const SEMICOLON	:uint = 186;
		public static const EQUAL			:uint = 187;
		public static const MINUS			:uint = 189;
		public static const SLASH			:uint = 191;
		public static const GRAVE			:uint = 192;
		public static const OPENBRACKET:uint = 219;
		public static const BACKSLASH	:uint = 220;
		public static const CLOSEBRACKET:uint = 221;
		public static const QUOTE			:uint = 222;
		//---------------------------------------------------------------------------------------------------------------------------------------------
	}
}

internal class Lock { };