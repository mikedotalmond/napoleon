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
	
	import de.nulldesign.nd2d.display.Polygon2D;
	import de.nulldesign.nd2d.geom.PolygonData;
	import de.nulldesign.nd2d.geom.Vertex;
	
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	
	
	 /**
	  * Adds a Nape phyiscs body and properties to a Polygon2D
	  * @see de.nulldesign.nd2d.display.Polygon2D
	  * @author Mike Almond - https://github.com/mikedotalmond
	  */
	public final class NapePolygon2D extends Polygon2D implements INapeNode {
		
		/**
		 * A short-cut to Polygon2D.regularPolygon with addCentralVertex=true
		 * Create a regular polygon (pent,hex,sept,dodeca etc..)
		 * @param	radius			Radius of created polygon
		 * @param	edges			Polygon edge count
		 * @return
		 */
		public static function regularPolygon(radius:Number, edgeCount:uint = 5):PolygonData {
			return Polygon2D.regularPolygon(radius, edgeCount, true);
		}
		
		/**
		 * Just a shortcut to Polygon2D.regularPolygon with a default of 32 subdivisions and with addCentralVertex=true, more of a pointer to how to create circles I guess..
		 * @param	radius
		 * @param	subdivisions
		 * @param	textureObject
		 * @param	colour
		 * @return
		 */
		public static function circle(radius:Number, subdivisions:uint = 24):PolygonData {
			return Polygon2D.regularPolygon(radius, subdivisions, true);
		}
		
		/**
		 * Create a Polygon object for the nape bodyshape
		 * @param	points - a convex polygon hull (vertices)
		 * @return	Polygon shape data
		 */
		static private function polyFromHull(points:Vector.<Vertex>):Polygon {
			points.fixed = true;
			var n:int = points.length;
			var a:/*Vec2*/Array = new Array();
			
			var i:int = -1;
			while (++i < n) a[i] = new Vec2(points[i].x, points[i].y);
			
			return new Polygon(a);
		}
		
		/**
		 * 
		 * @param	polygonData
		 * @param	textureObject
		 * @param	colour
		 */
		public function NapePolygon2D(polygonData:PolygonData, textureObject:Texture2D = null, colour:uint=0){
			super(polygonData, textureObject, colour);
		}
		
		/**
		 * construct the physics body and set the properties
		 * @param	position
		 * @param	isCircle
		 * @param	bodyType
		 * @param	physMaterial
		 * @return
		 */
		public function init(position:Vec2, isCircle:Boolean = false, bodyType:BodyType = null, physMaterial:Material = null):Body {
			
			initWithBody(position, new Body(bodyType == null ? BodyType.DYNAMIC : bodyType));
			_isCircle = isCircle;
			
			_body.shapes.add(isCircle ? new Circle(polygonData.bounds.width / 2) : polyFromHull(polygonData.polygonVertices));
			if(physMaterial) _body.setShapeMaterials(physMaterial);
			
			return _body;
		}
		
		
		public function initWithBody(position:Vec2, body:Body):void {
			_body 		= body;
			x 			= position.x;
			y 			= position.y;
			rotation 	= 0;
		}
		
		
		override protected function step(elapsed:Number):void {
			x 			= _body.position.x;
			y 			= _body.position.y;
			rotation	= _body.rotation * _180Pi;
		}
		
		override public function dispose():void {
			if (_body) {
				_body.clear();
				_body.space = null;
				_body 		= null;
			}
			super.dispose();
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
			if (_body) _body.rotation = value / _180Pi;
		}
		
		private var _body					:Body;
		public function get body()			:Body { return _body; }
		
		private var _isCircle				:Boolean;
		public function get isCircle()		:Boolean { return _isCircle; }
		
		private static const _180Pi			:Number = 180 / Math.PI;
	}
}
