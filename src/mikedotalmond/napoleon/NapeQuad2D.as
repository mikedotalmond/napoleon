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
	import de.nulldesign.nd2d.display.Quad2D;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.Quad2DColorMaterial;
	import flash.geom.Vector3D;
	import nape.constraint.Constraint;
	import nape.geom.Vec2;
	import nape.geom.Vec2List;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	
	 /**
	  * Adds a Nape phyiscs body and properties to a Quad2D
	  * @see de.nulldesign.nd2d.display.Quad2D
	  * @author Mike Almond - https://github.com/mikedotalmond
	  */
	public final class NapeQuad2D extends Quad2D implements INapeNode {
		
		/**
		 * 
		 * @param	pWidth
		 * @param	pHeight
		 */
		public function NapeQuad2D(pWidth:Number=1, pHeight:Number=1) {
			super(pWidth, pHeight);
			mouseEnabled = false;
		}
		
		/**
		 * construct the physics body and set the properties
		 * @param	position
		 * @param	vertices
		 * @param	bodyType
		 * @param	physMaterial
		 * @return
		 */
		public function init(position:Vec2, vertices:Vector.<Vector3D>=null, bodyType:BodyType = null, physMaterial:Material = null):Body {
			
			_body = new Body(bodyType == null ? BodyType.DYNAMIC : bodyType);
			
			if (vertices == null) {
				_body.shapes.add(new Polygon(Polygon.box(width, height), physMaterial));
			} else {
				if (vertices.length != 4) throw new RangeError("I'm a Quad, I need 4 vetices");
				setVertexPositions(vertices[0], vertices[1], vertices[2], vertices[3]);
			}
			
			x = position.x;
			y = position.y;
			rotation = 0;
			_body.userData.nd2d = this;
			return _body;
		}
		
		override public function copy():Node2D {
			var q:NapeQuad2D 	= new NapeQuad2D(_width, _height);
			q.material			= new Quad2DColorMaterial();
			q.init(Vec2.weak(), null, body.type, body.shapes.at(0).material);
			q.copyPropertiesOf(this);
			q.mouseEnabled = mouseEnabled;
			return q;
		}
		
		override public function setVertexPositions(v1:Vector3D, v2:Vector3D, v3:Vector3D, v4:Vector3D):void {
			_body.shapes.clear();
			_body.shapes.add(new Polygon([new Vec2(v1.x, v1.y), new Vec2(v2.x, v2.y), new Vec2(v3.x, v3.y), new Vec2(v4.x, v4.y)]));
			super.setVertexPositions(v1, v2, v3, v4);			
		}		
		
		override protected function step(elapsed:Number):void {
			x 			= _body.position.x;
			y 			= _body.position.y;
			if(body.allowRotation) rotation	= _body.rotation * _180Pi;
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
		public function setBodyNull():void {
			_body = null;
		}
		
		/* INTERFACE mikedotalmond.napoleon.INapeNode */
		public function scale(x:Number, y:Number):void {
			_scaleX 			*= x;
			_scaleY 			*= y;
			invalidateMatrix 	= true;
			if (_body) _body.scaleShapes(x, y);
		}
		
		/* INTERFACE mikedotalmond.napoleon.INapeNode */
		public function copyAsINapeNode():INapeNode {
			return copy() as INapeNode;
		}
		
		override public function set x(value:Number):void {
			if (_body) _body.position.x = value;
			super.x = value;
		}
		
		override public function set y(value:Number):void {
			if (_body) _body.position.y = value;
			super.y = value;
		}
		
		override public function set rotation(value:Number):void {
			super.rotation = value;
			if(!_body.type==BodyType.STATIC) _body.rotation = value / _180Pi;
		} 
		
		private var _body:Body;
		public function get body():Body { return _body; }
		
		private static const _180Pi:Number = 180 / Math.PI;	
	}
}