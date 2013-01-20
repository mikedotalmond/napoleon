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


package mikedotalmond.napoleon.forces {
		
	/**
	 * Point force field (attractor) with inverse-sqare falloff (~gravity)
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */

	import nape.geom.Vec2;
	import nape.phys.Body;

	final public class PointField {
		
		private const tempVec	:Vec2 = new Vec2();
		private const tempVec2	:Vec2 = new Vec2();
		
		private var list		:Vector.<Body>;
		private var _radius		:Number;		
		private var _invRadius	:Number;
		
		public var owner		:Body;
		public var mass			:Number;
		public var position		:Vec2;
		public var enabled		:Boolean
		
		public var force		:Number;
		public var maxVelocity	:Number = 1000;
		
		/**
		 * 
		 * @param	position
		 * @param	owner
		 * @param	radius
		 * @param	force
		 * @param	maxVelocity
		 */
		public function PointField(position:Vec2, owner:Body = null, radius:Number = 100, force:Number = 5, maxVelocity:Number = 250) {
			
			this.position 		= position	? position : owner.position;
			this.mass			= owner 	? owner.mass : 1;
			this.owner 			= owner;
			this.radius 		= radius;
			this.force			= force;
			this.maxVelocity 	= maxVelocity;
			
			list 				= new Vector.<Body>();
			enabled				= true;
		}
		
		
		/**
		 * 
		 */
		public function update():void {
			if (!enabled) return;
			
			var b:Body;
			var i:int = list.length;
			
			const x:Number = position.x;
			const y:Number = position.y;
			const m:Number = mass;
			
			var distance:Number;
			var dx		:Number;
			var dy		:Number;
			var theta	:Number;
			var f		:Number;
			var diRange	:Number;
			
			while (--i > -1) {
				b 			= list[i];
				dx 			= b.position.x - x;
				dy 			= b.position.y - y;
				distance 	= Math.sqrt( dx * dx + dy * dy );
				
				if (distance < radius) {
					
					distance 	= distance < 0 ? 0 : distance;
					diRange	= 1.0 - (distance * _invRadius);
					
					if(distance > 0) {
						f 		= -force * (diRange * (b.mass * m));
						theta	= Math.atan2(dy, dx);				
						tempVec.setxy(b.velocity.x + f * Math.cos(theta), b.velocity.y + f * Math.sin(theta));
					} 
					
					b.applyImpulse(tempVec, tempVec2);
					if (b.velocity.length > maxVelocity) b.velocity.length += (maxVelocity - b.velocity.length);// * 0.8;
				}				
			}
		}
		
		
		/**
		 * 
		 * @param	node
		 * @return	the new node count
		 */
		public function addBody(body:Body):int {
			list.fixed = false;
			if (body) list.push(body);
			list.fixed = true;
			return list.length;
		}
		
		
		/**
		 * 
		 * @param	node
		 * @return	the new node count
		 */
		public function removeBody(body:Body):int {
			const i:int = list.indexOf(body);
			if (i != -1) {
				list.fixed = false;
				list.splice(i, 1);
				list.fixed = true;
			}
			return list.length;
		}
		
		public function dispose():void {
			list = null;
			owner = null;
			position = null;
		}
		
		public function get radius():Number { return _radius; }		
		public function set radius(value:Number):void {
			_radius		= isNaN(value) ? Number.MAX_VALUE : value;
			_invRadius	= isNaN(value) ? Number.MIN_VALUE  : 1.0 / (value * value);
		}
	}
}