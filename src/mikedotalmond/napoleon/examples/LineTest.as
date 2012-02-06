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
			
			var line:QuadLine2D = new QuadLine2D(128);
			addChild(line);
			
			line.lineStyle(18, 0xff0000, 1);
			line.moveTo(stage.stageWidth / 2, stage.stageHeight / 2);
			line.lineTo(stage.stageWidth / 1.5, stage.stageHeight / 1.5);
			
			line.lineStyle(9, 0x80ff00, 0.5);
			line.moveTo(0, stage.stageHeight / 3);
			line.lineTo(stage.stageWidth, stage.stageHeight/1.25);
		}
	}
}