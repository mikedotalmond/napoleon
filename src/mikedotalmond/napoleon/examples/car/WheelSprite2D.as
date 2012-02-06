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
package mikedotalmond.napoleon.examples.car {
	
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import mikedotalmond.napoleon.NapeSprite2D;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	public final class WheelSprite2D extends NapeSprite2D {
		
		private var _v0x			:Number;
		private var _v0y			:Number;
		private var _v1x			:Number;
		private var _v1y			:Number;
		private var _skidVertices	:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D()]);
		
		public function WheelSprite2D(textureObject:Texture2D=null){
			super(textureObject);
		}
		
		override public function init(position:Vec2, bodyType:BodyType = null, shapeType:uint = NapeSprite2D.BODY_SHAPE_BOX, physMaterial:Material = null):Body {
			
			_v0x = -width / 2;
			_v0y = height / 2;
			
			_v1x = width / 2;
			_v1y = height / 2;
			
			_skidVertices.fixed = true;
			
			return super.init(position, BodyType.DYNAMIC, NapeSprite2D.BODY_SHAPE_BOX, null);
		}
		
		// global points for wheel skid-quad vertex positions
		// calculating top edge vertices ,current body position + offset(rotated to match the body)
		// store previous edge verts for the bottom edge
		public function getSkidVertices():Vector.<Vector3D> {
			
			const a			:Vec2   = body.position;
			const cosTheta	:Number = Math.cos(body.rotation);
			const sinTheta	:Number = Math.sin(body.rotation);
			
			// store last edge verts to complete the quad (2,3 - bottom)
			_skidVertices[2].x = _skidVertices[1].x;
			_skidVertices[2].y = _skidVertices[1].y;		
			_skidVertices[3].x = _skidVertices[0].x;
			_skidVertices[3].y = _skidVertices[0].y;
			
			// current edge verts (0,1 - top)
			_skidVertices[0].x = a.x + (_v0x * cosTheta - _v0y * sinTheta);
			_skidVertices[0].y = a.y + (_v0x * sinTheta + _v0y * cosTheta);
			_skidVertices[1].x = a.x + (_v1x * cosTheta - _v1y * sinTheta);
			_skidVertices[1].y = a.y + (_v1x * sinTheta + _v1y * cosTheta);
			
			return _skidVertices;
		}
	}
}