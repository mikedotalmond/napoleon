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
	import flash.geom.Rectangle;
	
	import mikedotalmond.napoleon.forces.PointField;
	import mikedotalmond.napoleon.NapePolygon2D;
	import mikedotalmond.napoleon.NapeScene2D;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.Material;
	
	public final class PointFieldTest extends NapeScene2D {
		
		static public const Logger	:ILogger = Logging.getLogger(PointFieldTest);		
		
		private var fields			:Vector.<PointField>;
		private var bodies			:Vector.<Body>;
		private var middle			:PointField;
		
		public function PointFieldTest(bounds:Rectangle = null) {
			super(new Rectangle( -6400, -6400, 6400 * 2, 6400 * 2));
			Logger.info("Testing infinite PointField(s) - all objects attract each other and there's a fixed-field in the middle to keep everything rotating about a central point");
			Logger.info("(it takes a minute or two to settle down...)");
			Logger.info("Use the mouse-wheel to zoom in/out");
		}
		
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			
			backgroundColor	= 0;
			mouseWheelZoom	= true;
			camera.zoom 	= 0.2;
			
			const n	:uint = 64;
			const w	:uint = stage.stageWidth >> 1;
			const h	:uint = stage.stageHeight >> 1;
			
			var i	:int;
			var j	:int;
			var poly:NapePolygon2D;
			
			middle 	= new PointField(new Vec2(w, h), null, NaN, 50, 200);
			fields	= new Vector.<PointField>(n, true);
			bodies	= new Vector.<Body>(n, true);
			
			i = n;
			while (--i > -1) {
				poly 	= new NapePolygon2D(NapePolygon2D.circle(12 + Math.random() * (i < 3 ? 128 : 24)), null, Math.random() * 0xffff6633);
				poly.init(getRandomBoundsPosition(), true, null, Material.sand());
				
				bodies[i] = poly.body;
				fields[i] = new PointField(null, poly.body, NaN, 0.05, 200);
				
				middle.addBody(poly.body);
				addChild(poly);
			}
			
			i = n;
			while (--i > -1) {
				j = n;
				while (--j > -1) {
					if (j != i) fields[i].addBody(bodies[j]);
				}
			}
		}
		
		override protected function step(elapsed:Number):void {
			var i:int = fields.length;
			
			middle.update();
			while (--i > -1) fields[i].update();
			
			super.step(elapsed);
		}
	}
}