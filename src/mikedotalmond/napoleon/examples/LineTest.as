package mikedotalmond.napoleon.examples {
	import de.nulldesign.nd2d.display.QuadLine2D;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import mikedotalmond.napoleon.NapeScene2D;
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	public final class LineTest extends NapeScene2D {
		
		public function LineTest(bounds:Rectangle=null) {
			super(bounds);
		}
		
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			mouseWheelZoom = true;
			
			var line:QuadLine2D = new QuadLine2D(256, true);
			addChild(line);
			
			line.lineStyle(16, 0xff0000, 0.5);
			line.moveTo(0, 0);
			line.lineTo(stage.stageWidth, stage.stageHeight);
			
			line.lineStyle(8, 0x80ff00, 0.5);
			//line.moveTo(stage.stageWidth, 0); // no moveTo? next draw will continue from last drawn quad
			line.lineTo(0, stage.stageHeight/2);
			
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
		}
	}
}