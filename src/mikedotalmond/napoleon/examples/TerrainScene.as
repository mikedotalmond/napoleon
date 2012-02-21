package mikedotalmond.napoleon.examples {
	
	import de.nulldesign.nd2d.display.Polygon2D;
	import de.nulldesign.nd2d.geom.PolygonData;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import mikedotalmond.napoleon.NapeScene2D;

	import nape.geom.Vec2;
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	public final class TerrainScene extends NapeScene2D {
		
		//[Embed(source="../../../../../nd2d/examples/assets/ceiling_texture.png")]
		[Embed(source="../../../../../nd2d/examples/assets/grass_ground.png")]
		protected static const GROUND	:Class;
		
		public function TerrainScene() {
			super();
		}
		
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			
			mouseWheelZoom = true;
			
			const b			:Bitmap 						= new GROUND();
			const bd		:BitmapData 					= b.bitmapData;
			const decomposer:MarchingConvexDecomposition	= new MarchingConvexDecomposition(space);
			
			decomposer.run(bd, new Vec2(0,0), 64, 4, 1);
			trace("decomposed.cells: " + decomposer.cells.length);
			
			var polyData:PolygonData = PolygonData.fromBodyShapes(decomposer.cells, bd.width, bd.height, decomposer.offset);
			trace("triangles: " + polyData.triangleVertices.length);
			
			var poly:Polygon2D = new Polygon2D(polyData, null, 0xff000000);
			//var poly:Polygon2D = new Polygon2D(polyData, Texture2D.textureFromBitmapData(new GROUND().bitmapData), 0xff000000);
			poly.material.asColorMaterial.debugTriangles = true;
			//poly.material.asTextureMaterial.uvScaleX = 1;
			//poly.x = 320;
			poly.y = 250;
			addChild(poly);			
			
			backgroundColor = 0x809070;
		}
	}
}