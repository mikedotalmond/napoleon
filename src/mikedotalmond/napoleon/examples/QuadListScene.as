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
	
	import de.nulldesign.nd2d.display.Quad2D;
	import de.nulldesign.nd2d.display.QuadList2D;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import mikedotalmond.napoleon.NapeScene2D;
		
	public final class QuadListScene extends NapeScene2D {
		
		static public const Logger:ILogger = Logging.getLogger(QuadListScene);		
		
		private var quadList:QuadList2D;
		
		
		public function QuadListScene():void {
			super();
			Logger.info("Testing QuadList extrusion. Pretty boring. No interactivity.");
		}
		
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			
			quadList = new QuadList2D(128, true);
			quadList.fillListWithQuads();
			quadList.addQuad(new Quad2D(100, 100));//0
			
			quadList.extrudeFromQuadAt(0, new Vector3D(0, -33), new Vector3D(0, -33), QuadList2D.EDGE_TOP);//1
			quadList.extrudeFromQuadAt(0, new Vector3D(33, 0), new Vector3D(33, 0), QuadList2D.EDGE_RIGHT);//2
			quadList.extrudeFromQuadAt(0, new Vector3D(0, 33), new Vector3D(0, 33), QuadList2D.EDGE_BOTTOM);//3
			quadList.extrudeFromQuadAt(0, new Vector3D(-33, 0), new Vector3D(-33, 0), QuadList2D.EDGE_LEFT);//4
			
			quadList.extrudeFromQuadAt(3, new Vector3D(-5, 25), new Vector3D(-5, 20), QuadList2D.EDGE_BOTTOM);
			quadList.extrudeFromLastQuad(new Vector3D(-10, 25), new Vector3D(-5, 20), QuadList2D.EDGE_BOTTOM);
			quadList.extrudeFromLastQuad(new Vector3D(-15, 25), new Vector3D(-5, 20), QuadList2D.EDGE_BOTTOM);
			quadList.extrudeFromLastQuad(new Vector3D(-25, 25), new Vector3D(-5, 20), QuadList2D.EDGE_BOTTOM);
			quadList.extrudeFromLastQuad(new Vector3D( -25, 25), new Vector3D( -5, 20), QuadList2D.EDGE_BOTTOM);
			quadList.extrudeFromLastQuad(new Vector3D(-35, 5), new Vector3D( -10, 5), QuadList2D.EDGE_BOTTOM);
			quadList.extrudeFromLastQuad(new Vector3D(-40, 5), new Vector3D( -20, 5), QuadList2D.EDGE_BOTTOM);
			quadList.extrudeFromLastQuad(new Vector3D(-20, 0), new Vector3D( -20, 0), QuadList2D.EDGE_BOTTOM);
			quadList.extrudeFromLastQuad(new Vector3D(-20, -5), new Vector3D( -20, 5), QuadList2D.EDGE_BOTTOM);
			quadList.extrudeFromLastQuad(new Vector3D(-20, 0), new Vector3D( -20, 0), QuadList2D.EDGE_BOTTOM);
			
			quadList.extrudeFromQuadAt(4, new Vector3D(-25, 5), new Vector3D(-25, -5), QuadList2D.EDGE_LEFT);
			quadList.extrudeFromLastQuad(new Vector3D(-25, 5), new Vector3D(-25, -5), QuadList2D.EDGE_LEFT);
			quadList.extrudeFromLastQuad(new Vector3D(-25, 5), new Vector3D(-25, -5), QuadList2D.EDGE_LEFT);
			quadList.extrudeFromLastQuad(new Vector3D(-25, 5), new Vector3D(-25, -5), QuadList2D.EDGE_LEFT);
			quadList.extrudeFromLastQuad(new Vector3D(-25, 5), new Vector3D(-25, -5), QuadList2D.EDGE_LEFT);
			quadList.extrudeFromLastQuad(new Vector3D(-25, 5), new Vector3D(-25, -5), QuadList2D.EDGE_LEFT);
			quadList.extrudeFromLastQuad(new Vector3D(-25, 5), new Vector3D(-25, -5), QuadList2D.EDGE_LEFT);
			quadList.extrudeFromLastQuad(new Vector3D(-25, 5), new Vector3D(-25, -5), QuadList2D.EDGE_LEFT);
			quadList.extrudeFromLastQuad(new Vector3D( -25, 5), new Vector3D(-25, -5), QuadList2D.EDGE_LEFT);
			quadList.extrudeFromLastQuad(new Vector3D(-25, -15), new Vector3D(-25, 15), QuadList2D.EDGE_LEFT);
			quadList.extrudeFromLastQuad(new Vector3D(-25, -15), new Vector3D(-25, 15), QuadList2D.EDGE_LEFT);
			quadList.extrudeFromLastQuad(new Vector3D(-25, -15), new Vector3D(-25, 15), QuadList2D.EDGE_LEFT);
			quadList.extrudeFromLastQuad(new Vector3D(-25, -15), new Vector3D(-25, 15), QuadList2D.EDGE_LEFT);
			quadList.extrudeFromLastQuad(new Vector3D(-25, -15), new Vector3D(-25, 15), QuadList2D.EDGE_LEFT);
			
			addChild(quadList);
			resize(stage.stageWidth, stage.stageHeight);
		}
		
		override public function resize(w:uint, h:uint):void {
			super.resize(w, h);
			if (quadList) {
				quadList.x = w >> 1;
				quadList.y = h >> 1;
			}
		}
		
		override public function dispose():void {
			quadList.dispose();
			quadList = null;
			super.dispose();
		}
	}
}