package mikedotalmond.napoleon.examples {
	
	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import mikedotalmond.napoleon.constraints.portal.Portal;
	import mikedotalmond.napoleon.constraints.portal.PortalManager;
	import mikedotalmond.napoleon.INapeNode;
	import mikedotalmond.napoleon.NapePolygon2D;
	import mikedotalmond.napoleon.NapeQuad2D;
	import mikedotalmond.napoleon.NapeScene2D;
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	
	/**
	 * Rough-ish port of the Nape portals demo (haXe)
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	public final class Portals extends NapeScene2D {
		
		static public const Logger:ILogger = Logging.getLogger(Portals);		
		
		private var hand	:PivotJoint;
		private var manager	:PortalManager;
		
		public function Portals(bounds:Rectangle=null) {
			super(bounds);
		}
		
		override protected function onAddedToStage(e:Event):void {
			Logger.info("Nape portals test...");
			
			super.onAddedToStage(e);
			
			createStageBorderBody();
			border.cbType = PortalManager.OBJECT;
			
			//-------------------------------------------------------------------------
			
			var a:Vector.<Vec2> = Vector.<Vec2>([	
												new Vec2(200,225),new Vec2(400,225),new Vec2(300,125),new Vec2(300,325),
												new Vec2(50,50),new Vec2(550,50),new Vec2(50,400),new Vec2(550,400)
											]);
			var s:Shape;
			var node:INapeNode;
			for each(var p:Vec2 in a) {
				node = new NapePolygon2D(NapePolygon2D.circle(12), null, 0xffff0000);
				(node as NapePolygon2D).init(p, true, BodyType.DYNAMIC);
				addChild((node as NapePolygon2D));
				(node as NapePolygon2D).body.cbType = PortalManager.PORTER;
			}
			
			//-------------------------------------------------------------------------
			
			var p1:Portal = genportal(new Vec2(100,225),new Vec2(1,0),150);
			var p2:Portal = genportal(new Vec2(500,225),new Vec2(-1,0),100);
			var p3:Portal = genportal(new Vec2(300,25),new Vec2(0,1),150);
			var p4:Portal = genportal(new Vec2(300,425),new Vec2(0,-1),100);
			
			p1.target = p2;
			p2.target = p3;
			p3.target = p4;
			p4.target = p1;
			
			p1.node.body.type = BodyType.KINEMATIC;
			p2.node.body.type = BodyType.KINEMATIC;
			p2.node.body.angularVel = 1;
			/*
			//funky portal body now :) ... many things wrong with this part of the port - and it breaks pretty easily
			node = new NapeQuad2D(84, 100);
			(node as NapeQuad2D).init(new Vec2(300, 225), null, BodyType.DYNAMIC);
			(node as NapeQuad2D).body.cbType = PortalManager.OBJECT;
			
			node.rotation = Math.PI / 4;
			addChild(node as NapeQuad2D);
			
			var q1:Portal = new Portal(node, node.body.localCOM.add(new Vec2( -8 / 2.1, -50)), new Vec2( -1, 0), 84);
			var q2:Portal = new Portal(node, node.body.localCOM.add(new Vec2( 8 / 2.1, 50)), new Vec2(1, 0), 84);
			q1.target = q2;
			q2.target = q1;
			*/
			//-------------------------------------------------------------------------
			
			hand = new PivotJoint(space.world,null,new Vec2(),new Vec2());
			hand.active = false;
			hand.stiff = false;
			hand.space = space;
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);			
			//-------------------------------------------------------------------------
			
			manager = new PortalManager();
			manager.init(space, this);
		}
		
		
		private function genportal(pos:Vec2,dir:Vec2,w:Number):Portal {
			
			var d	:Number 		= 8;
			var port:NapeQuad2D 	= new NapeQuad2D(d, w);
			port.init(pos, null, BodyType.STATIC);
			port.body.rotation = dir.angle;
			addChild(port);
			
			return new Portal(port, port.body.localCOM.add(new Vec2(d / 2.1, 0)), new Vec2(1, 0), w);
		}
		
		
		private function onMouseDown(e:MouseEvent):void {
			var mp:Vec2 = new Vec2(stage.mouseX, stage.mouseY);
			space.bodiesUnderPoint(mp).foreach(function(b:Body):void {
				if(b.isDynamic()) {
					hand.body2 = b;
					hand.anchor2 = b.worldToLocal(mp);
					hand.active = true;
				}
			});
		}
		
		private function onMouseUp(e:MouseEvent):void {
			hand.active = false;
		}
		
		override protected function step(elapsed:Number):void {
			
			space.liveBodies.foreach(function(p:Body):void {
				p.velocity.muleq(0.98);
				p.angularVel *= 0.98;
			});
			
			if (hand.active && hand.body2.space == null) { hand.body2 = null; hand.active = false; }
			hand.anchor1.setxy(mouseX, mouseY);
			
			super.step(elapsed);
		}
		
		override public function dispose():void {
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			hand.space 	= null;
			hand 		= null;
			manager.dispose();
			manager = null;
			super.dispose();
		}
	}
}