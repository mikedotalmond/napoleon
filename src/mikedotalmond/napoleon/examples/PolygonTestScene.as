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

	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	
	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Polygon2D;
	import de.nulldesign.nd2d.geom.PolygonData;
	import de.nulldesign.nd2d.materials.Polygon2DColorMaterial;
	import de.nulldesign.nd2d.materials.Polygon2DTextureMaterial;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import mikedotalmond.napoleon.INapeNode;
	import mikedotalmond.napoleon.NapePolygon2D;
	import mikedotalmond.napoleon.NapeScene2D;
	import mikedotalmond.napoleon.NapeSprite2D;
	
	import nape.geom.Vec2;
	import nape.phys.BodyType;
	import nape.phys.Material;
	
	
	public final class PolygonTestScene extends NapeScene2D {
		
		[Embed(source="../../../../assets/checks.png")] // 256x256 checkerboard
		private static const TextureBD	:Class;
		
		static public const Logger:ILogger = Logging.getLogger(TestScene2D);		
		
		private var testA	:Polygon2D;
		private var testB	:Polygon2D;
		private var testC	:Polygon2D;
		private var testD	:Polygon2D;
		private var testE	:NapePolygon2D;
		private var testF	:NapePolygon2D;
		private var testG	:NapePolygon2D;
		private var floor	:NapeSprite2D;
		
		public function PolygonTestScene() {
			super();
			Logger.info("Testing Polygon2D creation, texturing, and physics");
		}
		
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			
			space.gravity 		= new Vec2(0, 32);
			positionIterations = velocityIterations = 10;
			
			bounds.x 		= 	bounds.y 			= -100;
			bounds.width 	= stage.stageWidth  + 200;
			bounds.height = stage.stageHeight + 200;
			
			// Create some PolygonData to use when constructing new Polygon2D and NapePolygon2D objects
			// PolygonData constructor takes either a point-cloud or list of prepared vertices to calculate 
			// polygon properties and data for constructing new Polygon2D/NapePolygon2D instances
			const polygonData:PolygonData = new PolygonData(Vector.<Vector3D>([
				new Vector3D(0, -10), new Vector3D(100, 20), new Vector3D(50, -20), new Vector3D(150, 50),
				new Vector3D(65, 120), new Vector3D(20, 100), new Vector3D(120, 120), new Vector3D( -20, 50)])
			);
			
			// a polygon with flat colour
			testA = new Polygon2D(polygonData, null, 0xffff8080);
			testA.x = 240;
			testA.y = 160;
			addChild(testA);
			
			// a polygon with flat colour
			testB = new Polygon2D(polygonData, null, 0xffff8080);
			testB.x = 480;
			testB.y = 160;
			addChild(testB);
			
			// polygon with a bitmap texture (sprite sheets not yet implemented, but should be fairly straightforward)
			testC = new Polygon2D(polygonData, Texture2D.textureFromBitmapData(new TextureBD().bitmapData));
			(testC.material as Polygon2DTextureMaterial).uvScaleX = 0.5;
			(testC.material as Polygon2DTextureMaterial).uvScaleY = 0.5;
			testC.x = 720;
			testC.y = 160;
			addChild(testC);
			
			// polygon with a bitmap texture (sprite sheets not yet implemented, but should be fairly straightforward)
			testD = new Polygon2D(polygonData, Texture2D.textureFromBitmapData(new TextureBD().bitmapData));
			(testD.material as Polygon2DTextureMaterial).uvScaleX = 0.5;
			(testD.material as Polygon2DTextureMaterial).uvScaleY = 0.5;
			testD.x = 960;
			testD.y = 160;
			addChild(testD);
			
			
			//
			// regular polygons, circle, nape physics
			//
			
			// pentagons
			var n:int = 64;
			while (--n) {
				testE = new NapePolygon2D(NapePolygon2D.regularPolygon(20 + Math.random()*20,5), null, 0xffaed03c);
				testE.init(getRandomStagePosition(), false, null, Material.steel()); 
				addChild(testE);
			}
			
			// hexagon
			n = 6;
			while (--n) {
				testE = new NapePolygon2D(NapePolygon2D.regularPolygon(50,6), null, 0xff6699a9);
				testE.init(getRandomStagePosition(), false, null, Material.rubber()); 
				addChild(testE);
			}
			
			// octagon
			n = 8;
			while (--n) {
				testG = new NapePolygon2D(NapePolygon2D.regularPolygon(48,8), null, 0xfff9969a9);
				testG.init(getRandomStagePosition(), false, null, Material.wood()); 
				addChild(testG);
			}
			
			// circle
			n = 128;
			while (--n) {
				// calling NapePolygon2D.circle creates creates a poly with 24 subdivisions (close enough to a circle when not too large)
				testF = new NapePolygon2D(NapePolygon2D.circle(8 + Math.random()*32), Texture2D.textureFromBitmapData(new TextureBD().bitmapData));
				testF.init(getRandomStagePosition(), true, null, Material.glass()); // setting isCircle=true makes the Nape physics object a circle, not a polygon with many edges
				addChild(testF);
			}
			
			// test NapePolygon2D with the polygonData 
			var testH:NapePolygon2D = new NapePolygon2D(polygonData, null, (0xff <<24) | 0xffffff*Math.random());
			testH.init(getRandomStagePosition(), false, null, Material.glass());
			addChild(testH);
			
			// the ground object			
			floor = new NapeSprite2D(Texture2D.textureFromBitmapData(new BitmapData(stage.stage.fullScreenWidth, 64, false, 0xffff0000)))
			floor.init(new Vec2(stage.stageWidth >> 1, stage.stageHeight), BodyType.KINEMATIC, NapeSprite2D.BODY_SHAPE_BOX, Material.ice());
			addChild(floor);
		}
		
		override protected function step(elapsed:Number):void {
			super.step(elapsed);
			
			// test modifying some properties of the polygons
			// checking centre-of-mass (used for polygon registration/pivot point) and aspects of the UV mapping
			
			var n:uint = Math.floor (Math.random() * testA.material.indexCount);
			(testB.material as Polygon2DColorMaterial).modifyColorInBuffer(n, Math.random(), Math.random(), Math.random(), 1);			
			
			(testC.material as Polygon2DTextureMaterial).colorTransform.redOffset   = Math.sin(-(testD.material as Polygon2DTextureMaterial).uvOffsetX)*0xff;
			(testC.material as Polygon2DTextureMaterial).colorTransform.greenOffset = (testC.material as Polygon2DTextureMaterial).uvOffsetY * 0xff;
			
			(testD.material as Polygon2DTextureMaterial).uvOffsetX += 0.005;
			(testD.material as Polygon2DTextureMaterial).uvOffsetY = Math.sin((testD.material as Polygon2DTextureMaterial).uvOffsetX);// Math.random();
			testD.rotation += 1;
		}
		
		override public function resize(w:uint, h:uint):void {
			super.resize(w, h);
			
			if (floor) {
				floor.x = w >> 1;
				floor.y = h;
			}
			
			bounds.width	= stage.stageWidth  + 200;
			bounds.height	= stage.stageHeight + 200;
		}
		
		override protected function nodeLeavingBounds(node:Node2D):void {
			if (floor === node) return;
			
			var nd:INapeNode = node as INapeNode;
			if (nd) { // reset positions along the top of the stage
				nd.body.position.x 	= stage.stageWidth * 0.1 + Math.random() * stage.stageWidth * 0.8;
				nd.body.position.y 	= bounds.y + Math.random() * 50;
				nd.body.rotation 	= (Math.random() - 0.5) * Math.PI * 2;
				nd.body.angularVel 	= (Math.random() - 0.5) * 2;
				nd.body.velocity.x 	=  (Math.random() - 0.5) * 20;
				nd.body.velocity.y 	= Math.random() * 2;
			}
		}
		
		override public function dispose():void {
			super.dispose();
			floor = null;
			testA = null;
			testB = null;
			testC = null;
			testD = null;
			testE = null;
			testF = null;
			testG = null;
		}
	}
}