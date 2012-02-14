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
		}
	}
}