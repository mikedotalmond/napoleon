package mikedotalmond.napoleon.examples {
	
	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	import mikedotalmond.napoleon.NapeContainer2D;
	
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
			
			super.onAddedToStage(e);
			
			addSceneMouseJoint();
			
			portalContainer = new NapeContainer2D(space);
			porteecontainer = new NapeContainer2D(space);
			
			addChild(porteecontainer);
			addChild(portalContainer);
			
			createStageBorderBody();
			border.shapes.foreach(function(s:Shape):void { s.cbType = PortalManager.OBJECT } );
			border.cbType = PortalManager.OBJECT;
			
			//-------------------------------------------------------------------------
			
			var a:Vector.<Vec2> = Vector.<Vec2>([	
				new Vec2(200, 225), new Vec2(400, 225), new Vec2(300, 125), new Vec2(300, 325),
				new Vec2(50, 50), new Vec2(550, 50), new Vec2(50, 400), new Vec2(550, 400)
			]);
			
			var s:Shape;
			var node:INapeNode;
			for each(var p:Vec2 in a) {
				node = new NapePolygon2D(NapePolygon2D.circle(12), null, 0xffff0000);
				(node as NapePolygon2D).init(p, true, BodyType.DYNAMIC).cbType = PortalManager.PORTER;
				porteecontainer.addChild((node as NapePolygon2D));
			}
			
			//-------------------------------------------------------------------------
			
			p1 = genPortal(new Vec2(100, 225), new Vec2(1, 0), 150);
			p2 = genPortal(new Vec2(500, 225), new Vec2( -1, 0), 100);
			p3 = genPortal(new Vec2(300, 25), new Vec2(0, 1), 150);
			p4 = genPortal(new Vec2(300, 425), new Vec2(0, -1), 100);
			
			p1.target = p2;
			p2.target = p3;
			p3.target = p4;
			p4.target = p1;
			
			manager = new PortalManager();
			manager.init(space, porteecontainer);
			
			resize(_width, _height);
		}
		
		
		private function genPortal(pos:Vec2,dir:Vec2, w:Number):Portal {
			var h	:Number 	= 8;
			var port:NapeQuad2D = new NapeQuad2D(h, w);
			port.linearGradient(0x008080, 0xff0080, 1, 1, true);
			port.init(pos, null, BodyType.KINEMATIC);
			port.body.rotation = dir.angle;
			portalContainer.addChild(port);
			
			return new Portal(port, new Vec2(1, 0), h, w);
		}
		
		
		override protected function step(elapsed:Number):void {
			
			var h:Number = (_height * 0.5);
			var w:Number = (_width * 0.5);
			
			//p1.body.angularVel 	= Math.sin(space.elapsedTime * 0.115);
			//p4.body.position.x	= w + w * 0.6 * Math.sin(space.elapsedTime * 0.189);
			//p4.body.position.y	= h + h * 0.6 * Math.cos(space.elapsedTime * 0.129);
			
			space.liveBodies.foreach(function(p:Body):void {
				p.velocity.muleq(0.995);
				p.angularVel *= 0.995;
			});
			
			super.step(elapsed);
		}
		
		override public function dispose():void {
			manager.dispose();
			manager = null;
			super.dispose();
		}
		
		override public function resize(w:uint, h:uint):void {
			super.resize(w, h);
			if (p1) {
				p1.body.position.x = 48;
				p2.body.position.x = w - 48;
				p3.body.position.y = 48;
				p4.body.position.y = h - 48;
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