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
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import flash.events.Event;
	import nape.constraint.Constraint;
	import nape.phys.Material;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	
	 /**
	  * Adds a Nape phyiscs body and properties to Sprite2D
	  * @see de.nulldesign.nd2d.display.Sprite2D
	  * @author Mike Almond - https://github.com/mikedotalmond
	  */
	public class NapeSprite2D extends Sprite2D implements INapeNode {
		
		private static const _180Pi				:Number = 180 / Math.PI;
		public static const BODY_SHAPE_CIRCLE	:uint = 0;
		public static const BODY_SHAPE_BOX		:uint = 1;
		
		private var _body:Body;
		public function get body():Body { return _body; }
		
		
		/**
		 * 
		 * @param	textureObject
		 */
		public function NapeSprite2D(textureObject:Texture2D=null) {
			super(textureObject);
			mouseEnabled = false;			
		}
		
		/**
		 * construct the physics body and set the properties
		 * @param	position
		 * @param	bodyType
		 * @param	shapeType
		 * @param	physMaterial
		 * @return
		 */
		public function init(position:Vec2, bodyType:BodyType = null, shapeType:uint = NapeSprite2D.BODY_SHAPE_BOX, physMaterial:Material = null):Body {
			
			var b:Body = new Body(bodyType == null ? BodyType.DYNAMIC : bodyType);
			
			switch(shapeType) {
				case BODY_SHAPE_CIRCLE:
					b.shapes.add(new Circle(Math.max(width, height) / 2, null, physMaterial));
					break;
					
				case BODY_SHAPE_BOX:
					b.shapes.add(new Polygon(Polygon.box(width, height), physMaterial));
					break;
			}
			
			initWithBody(position, b);
			_body.userData.nd2d = this;
			return _body;
		}
		
		/**
		 * 
		 * @param	body
		 * @param	position
		 */
		public function initWithBody(position:Vec2, body:Body):void {
			_body = body;
			x = position.x;
			y = position.y;
			rotation = 0;
			_body.userData.nd2d = this;
		}
		
		override protected function step(elapsed:Number):void {
			x 			= _body.position.x;
			y 			= _body.position.y;
			rotation	= _body.rotation * _180Pi;
		}
		
		override public function dispose():void {
			if (_body) {
				_body.space = null;
				_body.userData.nd2d = null;
				while(!_body.constraints.empty()) _body.constraints.at(0).space = null; //(no lambdas)
				//_body.clear();
				_body = null;
			}
			super.dispose();
		}
		
		/* INTERFACE mikedotalmond.napoleon.INapeNode */
		public function clone():INapeNode {
			var node:NapeSprite2D = new NapeSprite2D(texture);
			node.initWithBody(Vec2.weak(), _body.copy());			
			node._scaleX = _scaleX;
			node._scaleY = _scaleY;
			return node;
		}
		
		/* INTERFACE mikedotalmond.napoleon.INapeNode */
		public function scale(x:Number, y:Number):void {
			_scaleX 			*= x;
			_scaleY 			*= y;
			invalidateMatrix 	= true;
			if (_body) _body.scaleShapes(x, y);
		}
		
		/* INTERFACE mikedotalmond.napoleon.INapeNode */
		public function copy():Node2D {
			return null;
		}
		
		/* INTERFACE mikedotalmond.napoleon.INapeNode */
		public function copyAsINapeNode():INapeNode {
			return copy() as INapeNode;
		}
		
		/* INTERFACE mikedotalmond.napoleon.INapeNode */
		public function setBodyNull():void {
			_body = null;
		}
		
		/* INTERFACE mikedotalmond.napoleon.INapeNode */
		override public function set x(value:Number):void {
			if (_body) _body.position.x = value;
			super.x = value;
		}
		
		/* INTERFACE mikedotalmond.napoleon.INapeNode */
		override public function set y(value:Number):void {
			if (_body) _body.position.y = value;
			super.y = value;
		}
		
		/* INTERFACE mikedotalmond.napoleon.INapeNode */
		override public function set rotation(value:Number):void {
			super.rotation = value;
			if (_body) _body.rotation = value / _180Pi;
		} 
	}
}