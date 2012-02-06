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
package mikedotalmond.napoleon.examples.car {
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	import de.nulldesign.nd2d.display.Node2D;
	import flash.events.Event;
	
	/**
	 * Car skidmarks, drawn by modifying QuadList vertex positions (extruding from last drawn)
	 * 
	 * Each wheel has a SkidList assigned to it, the maxSkidmarks is split over all wheels
	 */
	public final class Skidmarks extends Node2D {
		
		private var numSkids			:uint;
		private var maxSkidmarks	:uint;
		
		public var skids					:Vector.<SkidList>;
		
		public function Skidmarks(numSkids:uint, maxSkidmarks:uint = 1024) {
			super();
			this.numSkids 		= numSkids;
			this.maxSkidmarks 	= maxSkidmarks;
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }
		
        protected function addedToStage(e:Event):void {
			
            removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			skids = new Vector.<SkidList>(numSkids, true);
			var marksPerSkid:int = int((maxSkidmarks / numSkids) + 0.5);
			
			var i:int = numSkids;
			while (--i > -1) skids[i] = addChild(new SkidList(marksPerSkid)) as SkidList;
        }
		
		override public function dispose():void {
			super.dispose();
			skids = null;
		}
	}
}


import com.furusystems.logging.slf4as.ILogger;
import com.furusystems.logging.slf4as.Logging;
import de.nulldesign.nd2d.display.Quad2D;
import de.nulldesign.nd2d.display.QuadList2D;
import flash.geom.Vector3D;
import mikedotalmond.napoleon.examples.car.WheelSprite2D;

final internal class SkidList extends QuadList2D {
	
	private static const Logger	:ILogger = Logging.getLogger(SkidList);
	private var _active				:Boolean = false;
	
	public function SkidList(maxQuads:uint) {
		super(maxQuads, true);
		
		const skidQuad:Quad2D = new Quad2D(1, 1);
		skidQuad.bottomLeftColor = skidQuad.bottomRightColor = 
		skidQuad.topLeftColor 	 = skidQuad.topRightColor = 0x131313;
		
		super.fillListWithQuads(false, skidQuad);
		
		index = 0;
	}
	
	public function update(active:Boolean, wheel:WheelSprite2D, intensity:Number):void {
		if (active && intensity > 0) {
			
			const quad:Vector.<Vector3D> = wheel.getSkidVertices();
			
			if (_active) {
				quadList[index].setVertexPositions(quad[0], quad[1], quad[2], quad[3]);
				quadList[index].alpha = 0.1 + intensity * 0.25;
				if (++index == quadList.length) index = 0;
			}
		}
		
		_active = active;
	}
}