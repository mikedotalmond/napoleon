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

package mikedotalmond.napoleon {
	
	/**
	 * Container for INapeNode(s)
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	import flash.events.Event;
	import nape.space.Space;
	import de.nulldesign.nd2d.display.Node2D;
	
	public final class NapeContainer2D extends Node2D {
		
		private var _space:Space;
		
		public function NapeContainer2D(space:Space) {
			_space = space;
			super();
		}
		
		override public function addChildAt(child:Node2D, idx:uint):Node2D {
			if (child is INapeNode) (child as INapeNode).body.space = _space;
			children.fixed = false;
			super.addChildAt(child, idx);
			children.fixed = true;
			return child;
		}
		
		override public function removeChildAt(idx:uint):void {
			if (idx < children.length) {
				var s:INapeNode = children[idx] as INapeNode;
				
				children.fixed = false;
				super.removeChildAt(idx);
				children.fixed = true;
				
				if (s) s.dispose();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			_space = null;
		}
	}
}