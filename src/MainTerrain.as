package  {
	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.geom.PolygonData;
	import de.nulldesign.nd2d.utils.TextureHelper;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import nape.geom.Vec2;
	import nape.space.Space;
	import nape.util.ShapeDebug;
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	public final class MainTerrain extends Sprite {
		
		[Embed(source="../../nd2d/examples/assets/grass_ground.png")]
		protected static const GROUND	:Class;
		
		public function MainTerrain() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			const b			:Bitmap 						= new GROUND();
			const bd		:BitmapData 					= b.bitmapData;
			
			var space		:Space 							= new Space();
			var decomposer	:MarchingConvexDecomposition	= new MarchingConvexDecomposition(space);
			
			decomposer.run(bd, new Vec2(), 256, 2);
			trace("decomposed.cells: " + decomposer.cells.length);
			
			var polyData:PolygonData = PolygonData.fromBodyShapes(decomposer.cells, bd.width, bd.height, decomposer.offset);
			trace("triangles: " + polyData.triangles.length);
			
			var faces:Vector.<Face> = TextureHelper.generateMeshFaceListFromPolygonData(polyData);
			trace("faces: " + faces.length);
		}
	}
}