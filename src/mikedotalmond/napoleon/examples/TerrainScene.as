package mikedotalmond.napoleon.examples {
	
	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	import mikedotalmond.napoleon.NapePolygon2D;
	import mikedotalmond.napoleon.NapeQuad2D;
	import nape.phys.BodyType;
	import nape.phys.Material;
	
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
		private var poly:NapePolygon2D;
		
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
			space.gravity = new Vec2(0, 15);
			
			const b			:Bitmap 						= new GROUND();
			const bd		:BitmapData 					= b.bitmapData;
			const decomposer:MarchingConvexDecomposition	= new MarchingConvexDecomposition(space);
			
			var start:int = getTimer();
			
			decomposer.run(bd, new Vec2( -bd.width / 2, -bd.height / 2), 64, 4, 2, BodyType.DYNAMIC, Material.wood());
			
			var polyData:PolygonData = PolygonData.fromBodyShapes(decomposer.body, bd.width, bd.height);
			poly = new NapePolygon2D(polyData, null, 0xff000000);
			poly.initWithBody(new Vec2(640,360), decomposer.body);
			
			Logger.info("Took " + 
						(getTimer() - start) + // 30ms in standalone release player - about double that for the debug player (running a release build)
						"ms to decompose the bitmap (" +
						bd.width + "x" + bd.height + 
						") into a total of " + 
						decomposer.polyCount + 
						" polygons and " + 
						(polyData.triangleVertices.length / 3) + 
						" triangles");
						
			poly.material.asColorMaterial.debugTriangles = true;
			container.addChild(poly);			
			
			var floor:NapeQuad2D = new NapeQuad2D(1280, 50);
			floor.init(Vec2.weak(640, 720 - 25), null, BodyType.STATIC, Material.sand());
			addChild(floor);
		}
		
		override protected function step(elapsed:Number):void {
			super.step(elapsed);
		}
	}
}