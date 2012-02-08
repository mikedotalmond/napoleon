package mikedotalmond.napoleon.examples {
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import de.nulldesign.nd2d.display.QuadLine2D;
	
	import mikedotalmond.napoleon.NapeScene2D;
	
	public final class LineTest extends NapeScene2D {
		
		private var theta:Number = 0.0;
		private var line:QuadLine2D;
		
		public function LineTest(bounds:Rectangle=null) {
			super(bounds);
		}
		
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			mouseWheelZoom = true;
			
			line = new QuadLine2D(128, true);
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
			
			var w:int = stage.stageWidth / 2;
			var h:int = stage.stageHeight / 2;
			
			line.clear();
			line.lineStyle(8, 0x0080ff, 0.5);
			line.moveTo(0, h);
			line.curveThroughPoints(Vector.<Point>([
				new Point(0, h),
				new Point(480 + 320 * Math.sin(theta), h + Math.tan(theta) * 128),
				new Point(stage.stageWidth - 480 - 320 * Math.cos(theta), h - Math.cos(theta) * 128),
				new Point(stage.stageWidth, h)
			]), 32);
			
			line.lineStyle(8, 0xff, 0.5);
			line.moveTo(w, h);
			line.lineTo(w + Math.cos(theta-Math.PI) * w, h - Math.sin(theta-Math.PI) * h);
			
			line.lineStyle(8, 0xffff, 0.5);
			line.moveTo(w, h);
			line.lineTo(w - Math.cos(theta-Math.PI) * w, h + Math.sin(theta-Math.PI) * h);
			
			line.lineStyle(8, 0xff00, 0.5);
			line.moveTo(w, h);
			line.lineTo(w + Math.cos(theta+Math.PI/2) * w, h - Math.sin(theta+Math.PI/2) * h);
			
			line.lineStyle(8, 0xff0000, 0.5);
			line.moveTo(w, h);
			line.lineTo(w + Math.cos(theta-Math.PI/2) * w, h - Math.sin(theta-Math.PI/2) * h);
		}
	}
}