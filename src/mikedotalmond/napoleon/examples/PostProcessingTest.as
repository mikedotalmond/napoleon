/*
 * ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 * Author: Lars Gerckens
 * Copyright (c) nulldesign 2011
 * Repository URL: http://github.com/nulldesign/nd2d
 * Getting started: https://github.com/nulldesign/nd2d/wiki
 *
 *
 * Licence Agreement
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package mikedotalmond.napoleon.examples {

	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	
	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.TextureRenderer;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	
	import flash.events.Event;
	
	import mikedotalmond.napoleon.postprocess.PointLight;
	
	import tests.SideScrollerTest;


	/**
	 * testing PointLight - based on the ND2D tests.PostProcessingTest - same scene, different post-process
	 */
	public final class PostProcessingTest extends SideScrollerTest {
		
		static private const Logger		:ILogger = Logging.getLogger(PostProcessingTest);		
		
		private var pointLight			:PointLight;
        private var sceneNode			:Node2D;
        private var textureRenderer		:TextureRenderer;
        private var postProcessedScene	:Sprite2D;

        public function PostProcessingTest() {
            super();
			Logger.info("Testing napoleon.postprocess.PointLight - test scene taken from ND2D tests.PostProcessingTest");
        }

        override protected function addedToStage(e:Event):void {
            super.addedToStage(e);
			addEventListener(Event.RESIZE, onResize, false, 0, true);
			
            sceneNode = new Node2D();
			
            while(children.length > 0) {
                sceneNode.addChild(getChildAt(0));
                removeChildAt(0);
            }
			
            addChild(sceneNode);
            sceneNode.visible = false;
			
			var renderTexture:Texture2D = Texture2D.textureFromSize(stage.stageWidth, stage.stageHeight);
			
            textureRenderer 	= new TextureRenderer(sceneNode, renderTexture, 0.0, 0.0);
            addChild(textureRenderer);
			
			pointLight 					= new PointLight(stage.stageWidth, stage.stageHeight, textureRenderer.width, textureRenderer.height);
			//pointLight.size				= 32;
			//pointLight.backgroundLevel	= 0;
			//pointLight.saturationLevel	= 0.5;
			//pointLight.additiveLevel = 0.5;
			
			postProcessedScene 	= new Sprite2D(renderTexture);
            postProcessedScene.setMaterial(pointLight);
            postProcessedScene.x = textureRenderer.width  * 0.5;
            postProcessedScene.y = textureRenderer.height * 0.5;
            addChild(postProcessedScene);
        }
		
		private function onResize(e:Event):void {
			pointLight.stageResize(stage.stageWidth, stage.stageHeight);
		}
		
		private var count:Number = 0;
        override protected function step(elapsed:Number):void {
			pointLight.pctX = (0.5 + Math.sin(count/2.5) * 0.5);
			pointLight.pctY = (0.45 + Math.sin(Math.cos(count*1.25)) * 0.3);
			
			var sz:Number 	= 116 * ((stage.mouseX - (stage.stageWidth / 2)) / (stage.stageWidth / 2));
			sz			  	= sz < 0 ? -sz : sz;
			sz 				+= 16;
			pointLight.size = sz;
			
			super.step(elapsed);
			count += elapsed;
        }
		
		override public function dispose():void {
			stage.removeEventListener(Event.RESIZE, onResize);
			pointLight.dispose();
			super.dispose();
			sceneNode = null;
			pointLight = null;
			textureRenderer = null;
			postProcessedScene = null;
		}
    }
}

