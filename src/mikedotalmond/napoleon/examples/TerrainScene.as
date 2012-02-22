package mikedotalmond.napoleon.examples {
	
	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	import de.nulldesign.nd2d.display.Polygon2D;
	import de.nulldesign.nd2d.geom.PolygonData;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import flash.utils.getTimer;
	
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
				
		static public const Logger:ILogger = Logging.getLogger(TerrainScene);		
				
		//[Embed(source="../../../../../nd2d/examples/assets/ceiling_texture.png")]
		[Embed(source="../../../../../nd2d/examples/assets/grass_ground.png")]
		protected static const GROUND	:Class;
		
		public function TerrainScene() {
			super();
			Logger.info("Testing decomposition of a bitmap with alpha channel into a set of Nape objects, then a Polygon2D mesh");
		}
		
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			
			backgroundColor = 0x809070;
			mouseWheelZoom 	= true;
			
			const b			:Bitmap 						= new GROUND();
			const bd		:BitmapData 					= b.bitmapData;
			const decomposer:MarchingConvexDecomposition	= new MarchingConvexDecomposition(space);
			
			var start:int = getTimer();
			
			decomposer.run(bd, Vec2.get(0, 0), 64, 4, 1);
			
			var polyData:PolygonData 	= PolygonData.fromBodyShapes(decomposer.cells, bd.width, bd.height, decomposer.offset);
			var poly	:Polygon2D 		= new Polygon2D(polyData, null, 0xff000000);
			//var poly:Polygon2D = new Polygon2D(polyData, Texture2D.textureFromBitmapData(new GROUND().bitmapData), 0xff000000);
			
			Logger.info("Took " + 
						(getTimer() - start) + // 30ms in standalone release player - about double that for the debug player (running a release build)
						"ms to decompose the bitmap (" +
						bd.width + "x" + bd.height + 
						") into a total of " + 
						decomposer.cells.length + 
						" Nape bodies,consisting of " + 
						decomposer.polyCount + 
						" polygons,\nand then triangulate them all into a mesh containing " + 
						(polyData.triangleVertices.length / 3) + 
						" triangles");
			
			
			poly.material.asColorMaterial.debugTriangles = true;
			//poly.x = 320;
			poly.y = 250;
			addChild(poly);			
		}
	}
}