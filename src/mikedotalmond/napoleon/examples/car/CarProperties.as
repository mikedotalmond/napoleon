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
	
	import nape.geom.Vec2;
	import flash.geom.Rectangle;
	
	public final class CarProperties {
		
		public var shellRect				:Rectangle = new Rectangle(0, 0, 32, 64);
		public var wheelRect				:Rectangle = new Rectangle(0, 0, 16, 32);
		public var wheelPositions			:Vector.<Vec2> = Vector.<Vec2>([
												new Vec2( -16, 32), //fl
												new Vec2(16, 32),  //fr
												new Vec2( -15, -32), //rl
												new Vec2(15, -32)] //rr
											);
		
		public var dragLevel				:Number = 0.05;
		public var engineImpulse			:Number = 14;
		public var skidThreshold			:Vector.<Number> = Vector.<Number>([20, 20, 24, 24]);
		public var powerDistribution		:Vector.<Number> = Vector.<Number>([1, 1, 0.25, 0.25]);
		public var breakDistribution		:Vector.<Number> = Vector.<Number>([0.05, 0.05, 0.1, 0.1]);
		public var slipDistribution			:Vector.<Number> = Vector.<Number>([0.4, 0.4, 0.5, 0.5]);
		public var handbreakSlipDistribution:Vector.<Number> = Vector.<Number>([0.5, 0.5, 0.76, 0.76]);
		public var handbreakRetardation		:Vector.<Number> = Vector.<Number>([0.2, .2, 0.5, 0.5]);
		
		public var steerSpeed				:Number = 1;
		public var minSteeringAngle			:Vector.<Number> = Vector.<Number>([-0.45, -0.45, 0, 0]);
		public var maxSteeringAngle			:Vector.<Number> = Vector.<Number>([0.45, 0.45, 0, 0]);
		
		public function CarProperties() {
			wheelPositions.fixed =
			powerDistribution.fixed =
			slipDistribution.fixed =
			minSteeringAngle.fixed =
			maxSteeringAngle.fixed =
			handbreakSlipDistribution.fixed =
			handbreakRetardation.fixed =
			breakDistribution.fixed = true;
		}
	}
}