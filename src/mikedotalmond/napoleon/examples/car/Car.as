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
	
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	
	import flash.display.BitmapData;
	
	import mikedotalmond.napoleon.examples.car.Skidmarks;
	import mikedotalmond.napoleon.examples.car.TyreSmoke;
	import mikedotalmond.napoleon.NapeScene2D;
	import mikedotalmond.napoleon.NapeSprite2D;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	public final class Car  {
		
		public var shell				:NapeSprite2D;
		
		private var _wheels				:Vector.<WheelSprite2D>
		private var _wheelJoints		:Vector.<WheelJoint>
		private var numWheels			:uint;
		
		private var tyreSmoke			:TyreSmoke;
		private var skidmarks			:Skidmarks;
		
		public var skidWeights			:Vector.<Number>;
		
		public var accelerationInput	:Number;
		public var steeringInput		:Number;
		public var handbreakInput		:Boolean;
		
		public var speed				:Number;
		public var absSpeed				:Number;
		public var skidding				:Boolean;
		
		public var properties			:CarProperties;
		
		/**
		 * 
		 * @param	scene - scene to add the car to
		 * @param	_properties - CarProperties object
		 */
		public function Car(scene:NapeScene2D, _properties:CarProperties = null) {
			
			properties		= _properties || new CarProperties();
			numWheels  = properties.wheelPositions.length;
			
			skidmarks 	= new Skidmarks(numWheels, 1024);
			scene.addChild(skidmarks);
			
			tyreSmoke 	= new TyreSmoke(numWheels);
			skidWeights = tyreSmoke.smokeWeights;
			
			// just a simple bitmap texture for the car and wheels...
			shell = new NapeSprite2D(Texture2D.textureFromBitmapData(new BitmapData(properties.shellRect.width, properties.shellRect.height, false, 0xff3344aa)));
			shell.init(new Vec2(properties.shellRect.x,properties.shellRect.y), BodyType.DYNAMIC);
			
			_wheels 		= new Vector.<WheelSprite2D>(numWheels, true);
			_wheelJoints 	= new Vector.<WheelJoint>(numWheels, true);
			
			var wheelBd		:BitmapData = new BitmapData(properties.wheelRect.width, properties.wheelRect.height, false, 0xff09090a);
			var wheelTexture:Texture2D 	= Texture2D.textureFromBitmapData(wheelBd)
			var i:int = numWheels;
			
			while (--i > -1) {
				_wheels[i] = new WheelSprite2D(wheelTexture);
				_wheels[i].init(properties.wheelPositions[i], BodyType.DYNAMIC);
				_wheels[i].body.setShapeMaterials(new Material(0,1,2,0.75,0));
				_wheelJoints[i] = new WheelJoint(scene.space, shell.body, _wheels[i].body, properties.minSteeringAngle[i], properties.maxSteeringAngle[i]);
				scene.addChild(_wheels[i]);
			}
			
			shell.x = 1280;
			shell.y = 720;
			
			scene.addChild(shell);
			scene.addChild(tyreSmoke);			
		}
		
		// step through the simulation
		public function update():void {
			
			const v1:Vec2 	= new Vec2();
			const v2:Vec2 	= new Vec2();
			const p	:CarProperties = properties;
			
			rotate2DV(shell.body.velocity, -shell.body.rotation, v1); // overall linear velocity in direction of travel
			
			var vY			:Number 	= v1.y;
			var vM			:Number 	= v1.length;
			var absV		:Number 	= vY < 0 ? -vY : vY;
			var yDirection	:int 		= vY < 0 ? -1 : 1;
			var moving		:Boolean 	= absV > 0;
			var vYimpulse	:Number 	= 0;
			var breaking	:Boolean 	= (accelerationInput < 0 && vY > 1) || (accelerationInput > 0 && vY < -1);
			var skidding	:Boolean 	= false;
			var hbSkid		:Boolean 	= false;
			
			this.speed 		= vY;
			this.absSpeed 	= absV;
			
			if (moving) { // drag
				rotate2DYOnly(p.dragLevel * -vY, shell.body.rotation, v2); 
				shell.body.applyLocalImpulse(v2);
			}
			
			var maxSkid	:Number = 0;
			var delta	:Number;
			var body	:Body;
			var wheel	:WheelJoint;
			var i		:int = numWheels;
			while (--i > -1) { // process the inputs and forces on each wheel
				
				wheel 			= _wheelJoints[i];// as WheelJoint;
				body  			= wheel.body;
				vYimpulse 		= 0;
				wheel.skidding 	= hbSkid = false;
				
				if (wheel.hasMotor) { // steer, easing to input position
					delta = 	steeringInput < 0 ? -steeringInput * wheel.angle.jointMin : 
								(steeringInput > 0 ? steeringInput * wheel.angle.jointMax : 0);
					
					delta = wheel.body.rotation - (delta + shell.body.rotation);
					delta = ((delta < 0 ? -delta : delta) > 0.0001) ? delta : 0;
					
					wheel.motor.rate = delta * p.steerSpeed;					
				}
				
				if (breaking) { // breaking
					vYimpulse = p.breakDistribution[i];
					if (vYimpulse > 0) vYimpulse *= -vY;
				} else { // engine
					vYimpulse = p.powerDistribution[i];
					if (vYimpulse > 0) vYimpulse *= accelerationInput * p.engineImpulse;
				}
				
				// moving and handbreak-on?
				if (handbreakInput && absV > 1) {
					vYimpulse -= yDirection * p.handbreakRetardation[i];
					if (p.handbreakRetardation[i] > 0) {
						wheel.skidding = hbSkid = vM > 64; // rather arbitrary value...
						skidding ||= hbSkid;
					}
				}
				
				if (vYimpulse != 0) { // apply vYimpulse
					rotate2DYOnly(vYimpulse, body.rotation, v2);
					body.applyLocalImpulse(v2);
				}
				
				// kill sideways velocity. use gripDistribution to allow skidding
				rotate2DV(body.velocity, -(body.rotation), v1);
				v1.x *= (handbreakInput ? p.handbreakSlipDistribution[i] : p.slipDistribution[i]);
				
				delta = v1.x > 0 ? v1.x: -v1.x;
				if (delta > maxSkid) maxSkid = delta;
				if (delta > p.skidThreshold[i] || hbSkid) {
					wheel.skidding = skidding = true;
					skidWeights[i] = delta;
				}
				
				// re-align the velocity vector
				rotate2DV(v1, body.rotation, v2);
				// assign the modified value
				body.velocity.setxy(v2.x, v2.y);
				
				// update smoke data for the current wheel
				tyreSmoke.smokePositions[i].setTo(body.position.x, body.position.y);
				tyreSmoke.smokeVelocities[i].setTo(body.velocity.x / 50, body.velocity.y / 50); // another rather arbitrary value...
			}
			
			this.skidding = tyreSmoke.active = skidding;
			
			i = numWheels;
			while (--i > -1) {
				skidWeights[i] /= maxSkid;
				skidmarks.skids[i].update(_wheelJoints[i].skidding, _wheels[i], skidWeights[i]);
			}
		}
		
		public function dispose():void {
			
			shell.dispose();
			tyreSmoke.dispose();
			skidmarks.dispose();
			
			_wheels 		= null;
			_wheelJoints = null;
			skidWeights	= null;
			tyreSmoke 	= null;
			skidmarks 	= null;
			properties 		= null;
		}
		
		/**
		 * rotate just a vector by a theta radians
		 * @param	vIn
		 * @param	theta
		 * @param	vOut
		 */
		private static function rotate2DV(vIn:Vec2, theta:Number, vOut:Vec2):void {
			vOut.x = vIn.x * Math.cos(theta) - vIn.y * Math.sin(theta);
			vOut.y = vIn.x * Math.sin(theta) + vIn.y * Math.cos(theta);
		}
		
		/**
		 * rotate just the Y position (of a vector) by a theta radians
		 * @param	yIn
		 * @param	theta
		 * @param	vOut
		 */
		private static function rotate2DYOnly(yIn:Number, theta:Number, vOut:Vec2):void {
			vOut.x = -yIn * Math.sin(theta);
			vOut.y = yIn * Math.cos(theta);
		}
	}
}

import nape.constraint.AngleJoint;
import nape.constraint.MotorJoint;
import nape.constraint.PivotJoint;
import nape.phys.Body;
import nape.space.Space;

internal final class WheelJoint {
	
	public var body		:Body;
	public var pivot	:PivotJoint;
	public var angle	:AngleJoint;
	public var motor	:MotorJoint;
	public var hasMotor	:Boolean = false;
	public var skidding	:Boolean = false;
	
	// helper class for the wheel setup, contains the joints and motor for steering
	public function WheelJoint(space:Space, shell:Body, wheel:Body, minAngle:Number=-1, maxAngle:Number=1) {
		
		body = wheel;
		
		// pivot wheels about the car - follow main body rotation/*
		pivot 			= new PivotJoint(shell, wheel, wheel.position, shell.position);
		pivot.space 	= space;
		pivot.ignore 	= true;
		
		// limit wheel steering rotation
		angle 			= new AngleJoint(shell, wheel, minAngle, maxAngle);
		angle.space  	= space;
		angle.stiff 	= true;
		angle.maxForce 	= 100;
		angle.damping 	= 0.5;
		angle.ignore 	= true;
		
		if (minAngle != maxAngle) {
			hasMotor = true;
			// motor to apply rotation (steering input)
			motor 			= new MotorJoint(wheel, shell, 0, 1);
			motor.space  	= space;
			motor.ignore 	= true;
			motor.maxForce 	= 100;
			motor.damping 	= 0.85;
		}
	}
	
	public function dispose():void {
		body 		= null;
		
		pivot.space = null;
		pivot 		= null;
		angle.space = null;
		angle 		= null;
		
		if (motor) {
			motor.space = null;
			motor 		= null;
		}
	}
}