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
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mikedotalmond.napoleon.NapeScene2D;
	
	import de.nulldesign.nd2d.display.QuadLine2D;
	
	public final class LineTest extends NapeScene2D {
		
		static public const Logger	:ILogger 	= Logging.getLogger(QuadLine2D);		
		
		private var theta			:Number 	= 0.0;
		private var line			:QuadLine2D;
		
		public function LineTest(bounds:Rectangle=null) {
			super(bounds);
			Logger.info("Testing QuadLine2D line drawing methods");
		}
		
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			mouseWheelZoom = true;
			
			line = new QuadLine2D(256);
			addChild(line);
			/*
			line.lineStyle(16, 0xff0000, 0.5);
			line.moveTo(0, 0);
			line.lineTo(stage.stageWidth, stage.stageHeight);
			
			line.lineStyle(8, 0x00ff00, 0.5);
			line.moveTo(stage.stageWidth, 0);
			line.lineTo(0, stage.stageHeight);
			
			line.lineStyle(38, 0x80ff80, 0.5);
			line.moveTo(0, stage.stageHeight / 2);
			line.cubicCurveTo(
				stage.stageWidth / 2,  0,
				stage.stageWidth / 2 , stage.stageHeight,
				stage.stageWidth, stage.stageHeight / 2, 
				64
			);
			
			line.lineStyle(16, 0xf0af80, 0.5);
			line.moveTo(0, stage.stageHeight / 1.5);
			line.cubicCurveTo(
				stage.stageWidth / 2,  0,
				stage.stageWidth / 2 , stage.stageHeight,
				stage.stageWidth, stage.stageHeight / 1.5, 
				64
			);
			
			
			line.lineStyle(8, 0xff0080, 0.98);
			line.moveTo(0, stage.stageHeight / 1.5);
			line.cubicCurveTo(
				stage.stageWidth / 4,  0,
				stage.stageWidth / 8 , stage.stageHeight/4,
				stage.stageWidth/2, stage.stageHeight / 3, 
				64
			); 
			// no .moveTo(x,y) between 2 curves?... 
			// drawing will continue from the end of the last curve, but will not curve through - there will be a discontinuity
			line.lineStyle(8, 0x80ff00, 0.98);
			line.cubicCurveTo(
				stage.stageWidth/2,  stage.stageHeight/4,
				stage.stageWidth/2 , -stage.stageHeight/4,
				stage.stageWidth, stage.stageHeight/2, 
				64
			);
			
			*/
			
			// draw a curve from left to right
			/*line.lineStyle(8, 0x0080ff, 1);
			line.moveTo(0, stage.stageHeight / 2);
			line.curveThroughPoints(Vector.<Point>([
				new Point(0, stage.stageHeight / 2),
				new Point(480, (stage.stageHeight / 2) + 250),
				new Point(stage.stageWidth-320, (stage.stageHeight / 2) - 250),
				new Point(stage.stageWidth, stage.stageHeight / 2)
			]), 32);*/
		}
		
		override protected function step(elapsed:Number):void {
			super.step(elapsed);
			theta += elapsed;
			
			const w:int = _width / 2;
			const h:int = _height / 2;
			
			line.clear();
			line.lineStyle(12, 0xff80ff, 1, 1, 0xff, 0);
			line.moveTo(0, h);
			line.curveThroughPoints(Vector.<Point>([
				new Point(0, h),
				new Point(w/2 + 180 * Math.sin(theta + Math.PI / 2), h + Math.sin(theta) * 164),
				new Point(w + 180 * Math.sin(theta), h + Math.sin(theta) * 256),
				new Point(stage.stageWidth - 400 - 164 * Math.cos(theta), h - Math.cos(theta) * 256),
				new Point(stage.stageWidth, h)
			]), 16);
			
			line.lineStyle(4, 0xff, 0.5);
			line.moveTo(w, h);
			line.lineTo(w + Math.cos(theta-Math.PI) * w, h - Math.sin(theta-Math.PI) * h);
			
			line.lineStyle(8, 0xffffff, 0.5);
			line.moveTo(w, h);
			line.lineTo(w - Math.cos(theta-Math.PI) * w, h + Math.sin(theta-Math.PI) * h);
			
			line.lineStyle(16, 0xff00, 0.5);
			line.moveTo(w, h);
			line.lineTo(w + Math.cos(theta+Math.PI/2) * w, h - Math.sin(theta+Math.PI/2) * h);
			
			line.lineStyle(32, 0xff0000, 0.5);
			line.moveTo(w, h);
			line.lineTo(w + Math.cos(theta - Math.PI / 2) * w, h - Math.sin(theta - Math.PI / 2) * h);
			
			
			line.lineStyle(4, 0xff, 1, 1, 0xffff, 0);
			line.moveTo(w, h);
			line.lineTo(w + Math.cos(theta-Math.PI) * w, h - Math.sin(theta-Math.PI/4) * h);
			
			line.lineStyle(8, 0x333333, 0.5, 1, 0xffffff, 0.8);
			line.moveTo(w, h);
			line.lineTo(w - Math.cos(theta-Math.PI) * w, h + Math.sin(theta-Math.PI/4) * h);
			
			line.lineStyle(16, 0xff00, 0.5, 16, 0, 0, true);
			line.moveTo(w, h);
			line.lineTo(w + Math.cos(theta+Math.PI/2) * w, h - Math.sin(theta+Math.PI*1.4) * h);
			
			line.lineStyle(32, 0xff0000, 0, 8, 0, 1, true);
			line.moveTo(w, h);
			line.lineTo(w + Math.cos(theta-Math.PI/2) * w, h - Math.sin(theta-Math.PI*1.4) * h);
		}
	}
}