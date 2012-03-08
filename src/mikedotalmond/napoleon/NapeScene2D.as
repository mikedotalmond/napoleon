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
	
	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mikedotalmond.input.IGameController;
	
	import nape.geom.Vec2;
	import nape.space.Space;
	
	
	 /**
	  * @author Mike Almond - https://github.com/mikedotalmond
	  *
	 * Adds Nape physics Space to the Scene2D, so we can deal with INapeNode children
	 * */
	public class NapeScene2D extends Scene2D {
		
		private static const _180Pi:Number = 180 / Math.PI;
		
		private var _mouseWheelZoom:Boolean = false;
		public function get mouseWheelZoom():Boolean { return _mouseWheelZoom; }
		public function set mouseWheelZoom(value:Boolean):void {
			_mouseWheelZoom = value;
			if (stage) {
				if (value) stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelZoom, false, 0, true);
				else stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelZoom);
			}
		}
		
		protected function onMouseWheelZoom(e:MouseEvent):void {
			camera.zoom += e.delta / 300;
		}
		
		private var _gameController						:IGameController;
		public function get gameController()			:IGameController { return _gameController; }
		public function set gameController(value	:IGameController):void {
			if (_gameController) _gameController.update.remove(onControllerUpdate);
			_gameController = value;
			_gameController.update.add(onControllerUpdate);
		}
		
		private var _bounds				:Rectangle = null;
		
		public function get bounds()	:Rectangle { return _bounds; }
		
		public var spacePaused			:Boolean			= false;
		public var space				:Space				= new Space();
        public var container			:NapeContainer2D 	= new NapeContainer2D(space);
		
		public var velocityIterations	:uint 				= 10;
		public var positionIterations	:uint 				= 10;
		
		protected var border			:Body;
		
		/**
		 *  Construct a new NapeScene2D, optionally proviiding a bounding rectangle for the nodeLeavingBounds
		 */
		public function NapeScene2D(bounds:Rectangle = null) {
			super();
			_bounds = bounds || new Rectangle();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}
		
		protected function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			resize(stage.stageWidth, stage.stageHeight);
			mouseWheelZoom = _mouseWheelZoom;
		}
		
		protected function createStageBorderBody():void {
			border = new Body(BodyType.STATIC);
			border.shapes.add(new Polygon(Polygon.rect(0, 0, -50, stage.stageHeight)));
			border.shapes.add(new Polygon(Polygon.rect(stage.stageWidth, 0, 50, stage.stageHeight)));
			border.shapes.add(new Polygon(Polygon.rect(0, 0, stage.stageWidth, -50)));
			border.shapes.add(new Polygon(Polygon.rect(0, stage.stageHeight, stage.stageWidth, 50)));
			border.space = space;
		}
		
		override protected function step(elapsed:Number):void {
			
			if (!spacePaused) {
				// step through the physics simulation...
				space.step(1.0 / (elapsed * 1000), velocityIterations, positionIterations);
				
				const b:Rectangle = _bounds;
				
				if (b) { // have bounds set? check for nape objects leaving the bounds
					var n			:int = children.length;
					var nd			:INapeNode;
					while (--n > -1) {
						nd = children[n] as INapeNode;
						if (nd && nd.visible && (nd.x < b.left || nd.x > b.right || nd.y < b.top || nd.y > b.bottom)) nodeLeavingBounds(nd);
					}
				}
			}
		}
		
		protected function nodeLeavingBounds(node:INapeNode):void {
			// override as required...
		}
		
		protected function getRandomStagePosition():Vec2 {
			return new Vec2(stage.stageWidth * Math.random(), stage.stageHeight * Math.random());
		}
		
		protected function getRandomBoundsPosition():Vec2 {
			return new Vec2(bounds.x + bounds.width * Math.random(), bounds.y + bounds.height * Math.random());
		}
		
		public function resize(w:uint, h:uint):void {
			// override as required...
			_width  = w;
			_height = h;
		}
		
		public function onControllerUpdate():void {
			// override
		}
		
		override public function addChildAt(child:Node2D, idx:uint):Node2D {
			if (child is INapeNode) (child as INapeNode).body.space = space;
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
			
			_bounds = null;
			mouseWheelZoom = false;
			_gameController.update.remove(onControllerUpdate);
			_gameController.dispose();
			_gameController = null;
			camera.x = camera.y = 0;
			camera.zoom = 1;
			
			if (border != null) {
				border.space = null;
				border = null;
			}
			
			super.dispose();
			
			if (parent) parent.removeChild(this);
			
			container = null;
			
			space.clear();
			space = null;
		}
	}
}