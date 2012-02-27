package mikedotalmond.napoleon.examples {
	
	import com.furusystems.dconsole2.DConsole;
	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	
	import de.nulldesign.nd2d.display.QuadLine2D;
	import de.nulldesign.nd2d.geom.PolygonData;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import mikedotalmond.napoleon.INapeNode;
	import mikedotalmond.napoleon.BitmapToPolygon;
	import mikedotalmond.napoleon.NapePolygon2D;
	import mikedotalmond.napoleon.NapeScene2D;
	
	import nape.constraint.DistanceJoint;
	import nape.geom.Vec2;
	import nape.phys.BodyType;
	import nape.phys.Material;
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	public final class TerrainScene extends NapeScene2D {
		
		static public const Logger:ILogger = Logging.getLogger(TerrainScene);		
		
		//[Embed(source="../../../../../nd2d/examples/assets/ceiling_texture.png")]
		[Embed(source="../../../../../nd2d/examples/assets/grass_ground.png")]
		protected static const GROUND	:Class;
		private var bitmapPoly			:NapePolygon2D;
		
		private var pJoint1				:DistanceJoint;
		private var pJoint2				:DistanceJoint;
		private var jointLine			:QuadLine2D;
		private var platformPivot		:NapePolygon2D;
		
		private var debugTris			:Boolean = false;
		
		public function TerrainScene() {
			super();
			Logger.info("Testing decomposition of a bitmap with alpha channel into a series of convex Nape polygons, a Nape object, and a Polygon2D mesh");
			Logger.info("Also testing out the nape LineJoint, with QuadLine2D to draw lines between the anchors");
			Logger.info("Use 'debugTriangles' to see the triangles in the main mesh");
			
			DConsole.createCommand("debugTriangles", toggleDebugTriangles, null, "toggle a debug-draw mode on the main mesh so you can see the triangles")
		}
		
		private function toggleDebugTriangles():void {
			debugTris = !debugTris;
			if (debugTris) {
				bitmapPoly.material.asColorMaterial.randomiseVertexColors();
				platformPivot.material.asColorMaterial.randomiseVertexColors();
			} else {
				platformPivot.material.asColorMaterial.color = platformPivot.material.asColorMaterial.color;
				bitmapPoly.material.asColorMaterial.color = bitmapPoly.material.asColorMaterial.color;
			}
		}
		
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			
			space.gravity 		= new Vec2(0, 32);
			positionIterations 	= velocityIterations = 6;
			
			bounds.x 			= bounds.y 			= -100;
			bounds.width 		= stage.stageWidth  + 200;
			bounds.height 		= stage.stageHeight	+ 200;
			
			backgroundColor 	= 0x809070;
			mouseWheelZoom 		= true;
			
			doBitmapToPoly();
			setupJoints();
			
			
			var test:NapePolygon2D;
			// add some pentagons
			bounds.bottom = stage.stageHeight >> 1;
			var n:int = 256;
			while (--n) {
				test = new NapePolygon2D(NapePolygon2D.regularPolygon(10 + Math.random()*20,5), null, 0xffdad03c);
				test.init(getRandomBoundsPosition(), false, null, Material.steel()); 
				//test.material.asColorMaterial.debugTriangles = true;
				addChild(test);
			}
			
			// .. aand some hexagons, why not.
			n = 128
			while (--n) {
				test = new NapePolygon2D(NapePolygon2D.regularPolygon(15 + Math.random()*10,6), null, 0xffa3d0ac);
				test.init(getRandomBoundsPosition(), false, null, Material.wood()); 
				//test.material.asColorMaterial.debugTriangles = true;
				addChild(test);
			}
			
			bounds.bottom <<= 1;
		}
		
		private function doBitmapToPoly():void {
			
			const b				:Bitmap 			= new GROUND();
			const bd			:BitmapData 		= b.bitmapData;
			const bitmapToPoly	:BitmapToPolygon	= new BitmapToPolygon(space);
			const start			:int				= getTimer();
			
			bitmapToPoly.run(bd, new Vec2( -bd.width / 2, -bd.height / 2), 64, 4, 2, BodyType.DYNAMIC, Material.sand());
			
			const polyData:PolygonData 	= PolygonData.fromBodyShapes(bitmapToPoly.body, bd.width, bd.height);
			bitmapPoly 					= new NapePolygon2D(polyData, null, 0xff000000);
			bitmapPoly.initWithBody(new Vec2(640,560), bitmapToPoly.body);
			
			Logger.info("Took " + 
						(getTimer() - start) + // ~30ms in standalone release player - about double that for the debug player (running a release build)
						"ms to decompose the bitmap (" +
						bd.width + "x" + bd.height + 
						") into a total of " + 
						bitmapToPoly.polyCount + 
						" polygons and " + 
						(polyData.triangleVertices.length) + 
						" triangle vertices");
						
			// want to see the triangles?
			// bitmapPoly.material.asColorMaterial.debugTriangles = true;
			
			addChild(bitmapPoly);
			bitmapToPoly.dispose();
		}
		
		private function setupJoints():void {
			
			platformPivot = new NapePolygon2D(NapePolygon2D.regularPolygon(25,5), null, 0xffaed03c);
			platformPivot.init(new Vec2(stage.stageWidth>>1, 50), false, BodyType.KINEMATIC, Material.rubber()); 
			addChild(platformPivot);
			
			pJoint1 = new DistanceJoint(platformPivot.body, bitmapPoly.body, new Vec2( -15, 15), new Vec2( -bitmapPoly.width / 2, -50), 450, 475);
			pJoint1.breakUnderForce = false;
			pJoint1.breakUnderError = false;
			pJoint1.stiff 			= false;
			pJoint1.frequency 		= 0.25;
			pJoint1.space 			= space;
			
			pJoint2 = new DistanceJoint(platformPivot.body, bitmapPoly.body, new Vec2(15, 15), new Vec2(bitmapPoly.width / 2, -50), 450, 480);
			pJoint2.breakUnderForce = false;
			pJoint2.breakUnderError = false;
			pJoint2.stiff 			= false;
			pJoint2.frequency 		= 0.25;
			pJoint2.space 			= space;
			
			jointLine = new QuadLine2D(2);
			addChild(jointLine);
		}
		
		override protected function step(elapsed:Number):void {
			super.step(elapsed);
			
			jointLine.clear();
			jointLine.lineStyle(2, 0, 0.5);
			
			var d:Vec2 = pJoint1.body1.relativeToWorld(pJoint1.anchor1, true);
			jointLine.moveTo(d.x, d.y);
			d = pJoint1.body2.localToWorld(pJoint1.anchor2, true);
			jointLine.lineTo(d.x, d.y);
			
			d = pJoint2.body1.relativeToWorld(pJoint2.anchor1, true);
			jointLine.moveTo(d.x, d.y);
			d = pJoint2.body2.localToWorld(pJoint2.anchor2, true);
			jointLine.lineTo(d.x, d.y);
			
			var w2:Number = _width * 0.5;
			platformPivot.x = w2 - w2*0.25*Math.sin(count);
			platformPivot.y = 50 + 50 * Math.cos(count / 0.8);
			count += 0.005;
		}
		private var count:Number = 0.0;
		
		
		override public function resize(w:uint, h:uint):void {
			super.resize(w, h);
			
			if (bitmapPoly != null) {
				bitmapPoly.x = w >> 1;
				bitmapPoly.y = h-100;
			}
			
			bounds.width	= stage.stageWidth  + 200;
			bounds.height	= stage.stageHeight + 200;
		}
		
		override protected function nodeLeavingBounds(node:INapeNode):void {
			if (bitmapPoly === node) return;
			node.body.position.x 	= stage.stageWidth * 0.1 + Math.random() * stage.stageWidth * 0.8;
			node.body.position.y 	= bounds.y + Math.random() * 50;
			node.body.rotation 		= (Math.random() - 0.5) * Math.PI * 2;
			node.body.angularVel 	= (Math.random() - 0.5) * 2;
			node.body.velocity.x 	=  (Math.random() - 0.5) * 20;
			node.body.velocity.y 	= Math.random() * 2;
		}
		
		override public function dispose():void {
			
			super.dispose();
			
			DConsole.removeCommand("debugTriangles");
			
			pJoint1.space 	= null;	
			pJoint1 		= null;
			pJoint2.space 	= null;	
			pJoint2			= null;	
			bitmapPoly		= null;	
			jointLine		= null;	
			platformPivot 	= null;
		}
	}
}