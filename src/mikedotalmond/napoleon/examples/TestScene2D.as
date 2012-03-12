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
	
	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import mikedotalmond.napoleon.INapeNode;
	import mikedotalmond.napoleon.NapeQuad2D;
	import mikedotalmond.napoleon.NapeScene2D;
	import mikedotalmond.napoleon.NapeSprite2D;
	
	import nape.geom.Vec2;
	import nape.phys.BodyType;
	import nape.phys.FluidProperties;
	import nape.phys.Material;
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 * 
	 * The first test I made, showing some NapeSprite2D boxes with textures from bitmapData, and some NapeQuad2D shapes with the Quad2DColorMaterial
	 */
	
	public final class TestScene2D extends NapeScene2D {
		
		static public const Logger	:ILogger = Logging.getLogger(TestScene2D);		
		
		private var floor			:NapeSprite2D;
		private var water			:NapeSprite2D;
		private var count			:Number	= 0;
		
		/**
		 * 
		 */
		public function TestScene2D() {
			super();
			Logger.info("Testing Nape + ND2D set-up and performance (NapeScene2D, NapeSprite2D, NapeQuad2D)");
		}
		
		/**
		 * 
		 * @param	e
		 */
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			
			DConsole.createCommand("toggleWaterVisible", function():void {
				if (water) water.visible = !water.visible;
			});
			
			space.gravity 		= new Vec2(0, 38);
			positionIterations 	= velocityIterations = 12;
			
			// extend bounds beyond the visible on all sides - bounds used in NapeScene2D::nodeLeavingBounds
			bounds.x 		= 	bounds.y 		= -100;
			bounds.width 	= stage.stageWidth  + 200;
			bounds.height	= stage.stageHeight + 200;
			
			
			// create random size/position NapeSprite2Ds (with simple textures), and a few NapeQuad2Ds too
			
			var test	:NapeQuad2D;
			var n		:int = 320;
			
			while (--n) { 
				test = new NapeQuad2D(22 + int(24 * Math.random()), 22 + int(24 * Math.random()))
				test.flatColor(Math.random() * 0xff0000, 1);
				test.init(getRandomBoundsPosition(), null, BodyType.DYNAMIC, Material.wood());
				test.body.rotation = Math.random() * Math.PI * 2;		
				addChild(test);
			}
			
			// the ground - BodyType.KINEMATIC so it can be animated
			floor = new NapeSprite2D(Texture2D.textureFromBitmapData(new BitmapData(stage.stageWidth - 128, 64, false, 0xffff0000)));
			floor.init(new Vec2(stage.stageWidth >> 1, stage.stageHeight), BodyType.KINEMATIC, NapeSprite2D.BODY_SHAPE_BOX, Material.ice());
			addChild(floor);
			
			// the water rectangle... 
			water = new NapeSprite2D(Texture2D.textureFromBitmapData(new BitmapData(512, 256, false, 0xff0000cc)));
			water.init(new Vec2(0, 0), BodyType.KINEMATIC);
			water.body.shapes.at(0).fluidEnabled = true;
			water.body.setShapeFluidProperties(new FluidProperties(2,2));
			water.blendMode = BlendModePresets.FILTER;
			water.alpha = 0.9;
			addChild(water);
			
			resize(_width, _height);
		}
		
		override protected function step(elapsed:Number):void {
			super.step(elapsed);
			
			const w	:int = stage.stageWidth;
			const h	:int = stage.stageHeight;
			
			// animate floor and water body properties
			
			floor.body.position.x 	= (w >> 1);
			floor.body.position.y 	= h * 0.95 - (Math.sin(count/2) * h / 14);
			
			water.body.position.x 	= (w >> 1) - (Math.sin(count/2) * (w >> 2));
			water.body.position.y 	= (h  >> 1) + (Math.sin(count) * (h >> 3));
			water.body.rotation 	= Math.sin(count / Math.PI);
			
			count += elapsed;
		}
		
		override protected function nodeLeavingBounds(node:INapeNode):void {
			if (node == water || node == floor) return;
			
			// reset positions along the top of the stage
			node.body.velocity.x 	= node.body.velocity.y = 0;
			node.body.position.x 	= _width * 0.5 + (Math.random()-0.5) * _width * 0.8;
			node.body.position.y 	= bounds.y + Math.random() * 50;
			node.body.rotation 		= Math.random() * 6.28;
		}
		
		override public function resize(w:uint, h:uint):void {
			super.resize(w, h);
			bounds.width 	= stage.stageWidth  + 200;
			bounds.height 	= stage.stageHeight + 200;
		}
		
		override public function dispose():void {
			DConsole.removeCommand("toggleWaterVisible");
			super.dispose();
			floor = null;
			water = null;
		}
			
	}
}