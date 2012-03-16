package mikedotalmond.napoleon.examples {
	
	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	import mikedotalmond.napoleon.NapeContainer2D;
	import nape.dynamics.InteractionFilter;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mikedotalmond.napoleon.constraints.portal.Portal;
	import mikedotalmond.napoleon.constraints.portal.PortalManager;
	import mikedotalmond.napoleon.INapeNode;
	import mikedotalmond.napoleon.NapePolygon2D;
	import mikedotalmond.napoleon.NapeQuad2D;
	import mikedotalmond.napoleon.NapeScene2D;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Shape;
	
	/**
	 * Rough-ish port of the Nape portals demo - http://deltaluca.me.uk/docnew/swf/Portals.html
	 * 
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	public final class Portals extends NapeScene2D {
		
		static public const Logger	:ILogger = Logging.getLogger(Portals);		
		
		private var manager			:PortalManager;
		private var p1				:Portal;
		private var p2				:Portal;
		private var p3				:Portal;
		private var p4				:Portal;
		private var portalContainer	:NapeContainer2D;
		private var porteecontainer	:NapeContainer2D;
		
		public function Portals(bounds:Rectangle=null) {
			super(new Rectangle(0, 0, 1280, 720));
		}
		
		override protected function onAddedToStage(e:Event):void {
			Logger.info("Nape portals test...");
			positionIterations = velocityIterations = 10;
			super.onAddedToStage(e);
			
			addSceneMouseJoint();
			hand.maxForce = 250;
			
			space.gravity = new Vec2(0, 34);
			
			portalContainer = new NapeContainer2D(space);
			porteecontainer = new NapeContainer2D(space);
			
			addChild(porteecontainer);
			addChild(portalContainer);
			
			createStageBorderBody();
			//-------------------------------------------------------------------------
			
			var a:Vector.<Vec2> = Vector.<Vec2>([	
				new Vec2(600, 300), new Vec2(680, 300), new Vec2(600, 250), new Vec2(680, 250),
				new Vec2(600, 300), new Vec2(680, 300), new Vec2(600, 250), new Vec2(680, 250),
				new Vec2(600, 300), new Vec2(680, 300), new Vec2(600, 250), new Vec2(680, 250),
				new Vec2(600, 250), new Vec2(680, 250), new Vec2(600, 250), new Vec2(680, 250),
				new Vec2(600, 200), new Vec2(680, 200), new Vec2(600, 100), new Vec2(680, 100),
				new Vec2(600, 150), new Vec2(680, 150), new Vec2(600, 100), new Vec2(680, 100)
			]);
			
			var s:Shape;
			var node:INapeNode;
			for each(var p:Vec2 in a) {
				node = new NapePolygon2D(NapePolygon2D.circle(6), null, 0xffff0000);
				(node as NapePolygon2D).init(p, true, BodyType.DYNAMIC).cbType = PortalManager.PORTER;
				porteecontainer.addChild((node as NapePolygon2D));
			}
			
			//-------------------------------------------------------------------------
			
			p1 = genPortal(new Vec2(100, 225), new Vec2(1, -0.25), 250);
			p2 = genPortal(new Vec2(500, 225), new Vec2( 0, -1), 320);
			p3 = genPortal(new Vec2(300, 0), new Vec2(0, 1), 160);
			p4 = genPortal(new Vec2(300, 425), new Vec2(0, -1), 200);
			
			p1.target = p2;
			p2.target = p3;
			p3.target = p4;
			p4.target = p1;
			
			manager = new PortalManager();
			manager.init(space, porteecontainer, 0.5, 4);
			
			resize(_width, _height);
		}
		
		
		private function genPortal(pos:Vec2,dir:Vec2, w:Number):Portal {
			var h	:Number 	= 8;
			var port:NapeQuad2D = new NapeQuad2D(h, w);
			port.linearGradient(0xff0000, 0xff000, 1, 0.8, true);
			port.init(pos, null, BodyType.KINEMATIC);
			port.body.rotation = dir.angle;
			portalContainer.addChild(port);
			
			return new Portal(port, new Vec2(1, 0), h, w);
		}
		
		
		override protected function step(elapsed:Number):void {
			
			var h:Number = (_height * 0.5);
			var w:Number = (_width * 0.5);
			
			space.liveBodies.foreach(limitVelocity);
			
			/*
			if (mouseIsDown) {
				p4.node.x += (stage.mouseX - p4.node.x) * 0.1;
				p3.node.x += (_width-stage.mouseX - p3.node.x) * 0.1;
			} else {
				p4.node.x += (_width/2 - p4.node.x) * 0.1;
				p3.node.x += (_width-_width/2 - p3.node.x) * 0.1;
			}*/
			
			super.step(elapsed);
		}
		
		private static function limitVelocity(b:Body):void {
			b.velocity.muleq(0.988);
			b.angularVel *= 0.988;
		}
		
		override public function dispose():void {
			manager.dispose();
			manager = null;
			super.dispose();
		}
		
		override public function resize(w:uint, h:uint):void {
			super.resize(w, h);
			if (p1) {
				var hw:Number = 640;// w >> 1;
				var hh:Number = 360;// h >> 1;
				
				p1.body.position.x = 164;
				p1.body.position.y = hh;
				
				p2.body.position.x = hw - 260;
				p2.body.position.y = 720 - 40;
				
				p3.body.position.x = hw-64;
				p3.body.position.y = 64;
				
				p4.body.position.x = hw;
				p4.body.position.y = 720 - 132;
			}
			bounds.width  = w + 100;
			bounds.height = h + 100;
		}
		
		override protected function nodeLeavingBounds(node:INapeNode):void {
			if (node.body.type == BodyType.DYNAMIC) {
				node.body.position.set(getRandomStagePosition());
			}
		}
	}
}