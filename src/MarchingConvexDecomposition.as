package {
	
	import de.nulldesign.nd2d.display.Polygon2D;
	import de.nulldesign.nd2d.geom.PolygonData;
	import flash.display.BitmapData;
	
	import nape.geom.AABB;
	import nape.geom.GeomPoly;
	import nape.geom.GeomPolyList;
	import nape.geom.MarchingSquares;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Compound;
	import nape.phys.Material;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	import nape.space.Space;
	
	/**
	 * Based on code from the terrain marching-squares + convex decomposition demo for Nape
	 */
	
	public final class MarchingConvexDecomposition {
		
		private var cellsize	:Number;
		private var subsize		:Number;
		private var bounds		:AABB;
		private var width		:int;
		private var height		:int;
		private var offset		:Vec2;
		
		public var bitmap		:BitmapData;
		
		public var space		:Space;
		public var cells		:Vector.<Body>;
		public var body			:Body;
		public var marchQuality	:int;
		public var polyCount	:int;
		
		public function MarchingConvexDecomposition(space:Space):void {
			this.space = space;
		}
		
		public function run(bitmap:BitmapData, offset:Vec2, cellsize:Number, subsize:Number, marchQuality:int = 2, bodyType:BodyType = null, material:Material = null):void {
			
			this.bitmap 		= bitmap;
			this.offset 		= offset;
			this.cellsize 		= cellsize;
			this.subsize 		= subsize;
			this.marchQuality 	= marchQuality;
			
			if (bodyType == null) bodyType = BodyType.DYNAMIC;
			
			width  	= int(Math.ceil(bitmap.width / cellsize));
			height 	= int(Math.ceil(bitmap.height / cellsize));
			cells	= new Vector.<Body>(width * height, true);
			body 	= new Body(bodyType);
			
			invalidate(new AABB(0, 0, bitmap.width, bitmap.height), bodyType, material);
			
			cells.fixed = false;
			
			var i:int = -1;
			var n:int = cells.length;
			var b:Body
			while (++i < n) {
				b = cells[i];
				if (b == null) {
					cells.splice(i, 1);
					n--;
					i--;
				} else {
					// re assign all the shapes into a single nape body...
					b.shapes.foreach(function(p:Shape):void {
						var p2:Polygon = Shape.copy(p).castPolygon;
						p2.localVerts.foreach(function(v:Vec2):void {
							v.addeq(b.position);
						});
						body.shapes.add(p2);
					});
					
					b.space = null;
					b.clear();
				}
			}
			
			cells.length 	= 0;
			cells 			= null;
			body.space		= space;
		}
		
		//invalidate a region of the terrain to be regenerated.
		public function invalidate(region:AABB, bodyType:BodyType, polyMaterial:Material = null):void {
			bitmap.lock();
			polyCount 	= 0;
			bounds 		= new AABB(0, 0, cellsize, cellsize);
			//compute effected cells
			var x0:int = int(region.min.x/cellsize); if(x0<0) x0 = 0;
			var y0:int = int(region.min.y/cellsize); if(y0<0) y0 = 0;
			var x1:int = int(region.max.x/cellsize); if(x1>= width) x1 = width-1;
			var y1:int = int(region.max.y/cellsize); if(y1>=height) y1 = height-1;
			
			var b		:Body;
			var polys	:GeomPolyList;
			var qs		:GeomPolyList;
			var x:int, y:int;
			for(y = y0; y<=y1; y++) {
				for(x = x0; x<=x1; x++) {
					b = cells[int(y * width + x)];
					if (b != null) { // if cell body exists, clear it for re-use
						b.space = null;
						b.clear();
						b.position = offset;
						b.userData = this;
					}
					
					//compute polygons in cell
					bounds.x = x*cellsize;
					bounds.y = y*cellsize;
					polys = MarchingSquares.run(iso, bounds, Vec2.weak(subsize, subsize), marchQuality);
					if (polys.length == 0) continue;
					
					if (b == null) {
						cells[int(y * width + x)] = b = new Body(BodyType.STATIC, offset);
						b.userData = this;
					}
					
					//decompose polygons and generate the cell body.
					polys.foreach(function (p:GeomPoly):void {
						qs = p.convex_decomposition();
						qs.foreach(function (q:GeomPoly):void {
							b.shapes.add(new Polygon(q, polyMaterial));
							polyCount++;
						});
					});
				}
			}
			
			bitmap.unlock();
		}

		//iso-function for terrain, computed as a linearly-interpolated alpha threshold from bitmap.
		internal function iso(x:Number,y:Number):Number {
			var ix:int = int(x); if(ix<0) ix = 0; else if(ix>=bitmap.width)  ix = bitmap.width -1;
			var iy:int = int(y); if(iy<0) iy = 0; else if(iy>=bitmap.height) iy = bitmap.height-1;
			var fx:Number = x - ix; if(fx<0) fx = 0; else if(fx>1) fx = 1;
			var fy:Number = y - iy; if(fy<0) fy = 0; else if(fy>1) fy = 1;
			const gx:Number = 1-fx;
			const gy:Number = 1-fy;
			
			const a00:int = bitmap.getPixel32(ix,iy)>>>24;
			const a01:int = bitmap.getPixel32(ix,iy+1)>>>24;
			const a10:int = bitmap.getPixel32(ix+1,iy)>>>24;
			const a11:int = bitmap.getPixel32(ix+1,iy+1)>>>24;
			
			const ret:Number = gx*gy*a00 + fx*gy*a10 + gx*fy*a01 + fx*fy*a11;
			return 0x80 - ret;
		}
	}
}