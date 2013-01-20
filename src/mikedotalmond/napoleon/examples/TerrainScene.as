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
	import mikedotalmond.napoleon.util.BitmapToPolygon;
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
		private var jointLines			:QuadLine2D;
		private var platformPivot		:NapePolygon2D;
		
		private var debugTris			:Boolean = false;
		
		public function TerrainScene() {
			super();
		}
		
		private function toggleDebugTriangles():void {
			debugTris = !debugTris;
			if (debugTris) { // randomise vertex colours so we can see the triangles...
				bitmapPoly.material.asColorMaterial.randomiseVertexColors();
				platformPivot.material.asColorMaterial.randomiseVertexColors();
			} else {
				platformPivot.material.asColorMaterial.color = platformPivot.material.asColorMaterial.color;
				bitmapPoly.material.asColorMaterial.color = bitmapPoly.material.asColorMaterial.color;
			}
		}
		
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			
			Logger.info("Testing decomposition of a bitmap with alpha channel into a series of convex Nape polygons, a Nape object, and a Polygon2D mesh");
			Logger.info("Also testing out the nape LineJoint, with QuadLine2D to draw lines between the anchors");
			Logger.info("Use 'debugTriangles' to see the triangles in the main mesh");
			
			DConsole.createCommand("debugTriangles", toggleDebugTriangles, null, "toggle a debug-draw mode on the main mesh so you can see the triangles");
			
			space.gravity 		= new Vec2(0, 32);
			positionIterations 	= velocityIterations = 6;
			
			bounds.x 			= bounds.y 			= -100;
			bounds.width 		= stage.stageWidth  + 200;
			bounds.height 		= stage.stageHeight	+ 200;
			
			backgroundColor 	= 0x809070;
			mouseWheelZoom 		= true;
			
			// convert the input bitmapdata to a NapePolygon2D (should probably be Mesh2D I guess... refactor pending I think.)
			doBitmapToPoly();
			
			// suspend the created polygon mesh from two line joints to make swinging platform...
			setupJoints();
			
			// add a load of falling nape objects...
			makeFallingObjects();
		}
		
		/**
		 * convert the embedded bitmap data to a nape body and triangle mesh
		 */
		private function doBitmapToPoly():void {
			
			const b				:Bitmap 			= new GROUND();
			const bd			:BitmapData 		= b.bitmapData;
			const bitmapToPoly	:BitmapToPolygon	= new BitmapToPolygon(space);
			const start			:int				= getTimer();
			
			// decomposition of an input bitmap into a NapePolygon2D...
			// alpha-bitmap 		--> polygons (via MarchingSquares in BitmapToPolygon::run)
			// polygon(s) 		--> convex polygon(s)(via GeomPoly::convex_decomposition)
			// convex polygon(s)	=== Nape Polygon Shape(s)
			// convex polygon(s)	--> Nape Body
			// convex polygon(s)	--> Vertex list (triangles) (via PolyUtils.triangulateConvexPolygon (in PolygonData.fromNapeBodyShapes))
			
			bitmapToPoly.run(bd, new Vec2( -bd.width / 2, -bd.height / 2), 64, 4, 2, BodyType.DYNAMIC, Material.sand());
			
			const polyData:PolygonData 	= PolygonData.fromNapeBodyShapes(bitmapToPoly.body.shapes, bd.width, bd.height);
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
						" triangle vertices.");
			
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
			
			// a QuadLine2D with 2 quads to draw between the joint anchor points
			jointLines = new QuadLine2D(2);
			addChild(jointLines);
		}
		
		/**
		 * 
		 */
		private function makeFallingObjects():void {
			var test:NapePolygon2D;
			// ... some pentagons
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
		
		
		/**
		 * 
		 * @param	elapsed
		 */
		override protected function step(elapsed:Number):void {
			super.step(elapsed);
			
			// redraw the joint lines...
			jointLines.clear();
			jointLines.lineStyle(2, 0, 0.5);
			
			var d:Vec2 = pJoint1.body1.localPointToWorld(pJoint1.anchor1, true);
			jointLines.moveTo(d.x, d.y);
			d = pJoint1.body2.localPointToWorld(pJoint1.anchor2, true);
			jointLines.lineTo(d.x, d.y);
			
			d = pJoint2.body1.localPointToWorld(pJoint2.anchor1, true);
			jointLines.moveTo(d.x, d.y);
			d = pJoint2.body2.localPointToWorld(pJoint2.anchor2, true);
			jointLines.lineTo(d.x, d.y);
			
			// move the joint pivot point about a bit
			var w2:Number = _width * 0.5;
			platformPivot.x = w2 - w2 * 0.25 * Math.sin(theta);
			platformPivot.y = 75 + 75 * Math.cos(theta / 0.8);
			theta += 0.005;
		}
		
		private var theta:Number = 0.0;
		
		
		
		/**
		 * 
		 * @param	w
		 * @param	h
		 */
		override public function resize(w:uint, h:uint):void {
			super.resize(w, h);
			
			if (bitmapPoly != null) {
				bitmapPoly.x = w >> 1;
				bitmapPoly.y = h-100;
			}
			
			bounds.width	= stage.stageWidth  + 200;
			bounds.height	= stage.stageHeight + 200;
		}
		
		
		/**
		 * 
		 * @param	node
		 */
		override protected function nodeLeavingBounds(node:INapeNode):void {
			if (bitmapPoly === node) return;
			node.body.position.x 	= stage.stageWidth * 0.1 + Math.random() * stage.stageWidth * 0.8;
			node.body.position.y 	= bounds.y + Math.random() * 50;
			node.body.rotation 		= (Math.random() - 0.5) * Math.PI * 2;
			node.body.angularVel 	= (Math.random() - 0.5) * 2;
			node.body.velocity.x 	=  (Math.random() - 0.5) * 20;
			node.body.velocity.y 	= Math.random() * 2;
		}
		
		
		/**
		 * 
		 */
		override public function dispose():void {
			
			DConsole.removeCommand("debugTriangles");
			
			pJoint1.space 	= null;	
			pJoint1 		= null;
			pJoint2.space 	= null;	
			pJoint2			= null;	
			bitmapPoly		= null;	
			jointLines		= null;	
			platformPivot 	= null;
			
			super.dispose();
			
		}
	}
}