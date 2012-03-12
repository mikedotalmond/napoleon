package mikedotalmond.napoleon.constraints.portal {

	import de.nulldesign.nd2d.display.Node2D;
	import mikedotalmond.napoleon.INapeNode;
	import mikedotalmond.napoleon.NapeScene2D;
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.callbacks.PreListener;
	import nape.dynamics.Arbiter;
	import nape.dynamics.ArbiterList;
	import nape.dynamics.CollisionArbiter;
	import nape.dynamics.Contact;
	import nape.dynamics.ContactList;
	import nape.phys.Body;
	import nape.space.Space;

	final public class PortalManager {
		
		//portal sensors.
		public static const PORTAL	:CbType = new CbType();
		public static const OBJECT	:CbType = new CbType();
		
		public static const PORTER	:CbType	= new CbType(); //object that can be teleported.
		public static const INOUT	:CbType = new CbType(); //object which is part of an on-going portal interaction (in limbo)
		
		public var infos  			:Vector.<PortalInfo>;
		public var limbos 			:Vector.<Limbo>;
		
		private var space			:Space;
		private var container		:Node2D;
		
		public function PortalManager() {
			infos   = new Vector.<PortalInfo>();
			limbos  = new Vector.<Limbo>();
		}
		
		public function init(space:Space, container:Node2D):void {
			//ignore relevant contacts for shapes in limbo
			this.space = space;
			this.container = container;
			
			space.listeners.add(new PreListener(InteractionType.COLLISION, OBJECT, INOUT, onPreCollision));
			space.listeners.add(new PreListener(InteractionType.COLLISION, INOUT, INOUT, onPreCollision));
			space.listeners.add(new PreListener(InteractionType.COLLISION, PORTER, INOUT, onPreCollision));
			
			//ignore portal interactions
			space.listeners.add(new PreListener(InteractionType.ANY, PORTER, PORTAL, onPreCollisionIgnore));
			space.listeners.add(new PreListener(InteractionType.ANY, INOUT, PORTAL, onPreCollisionIgnore));
			
			space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.ANY, PORTAL, INOUT, onPortalInteractionEnd));			
			space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.ANY, PORTAL, INOUT, onPortalInteractionBegin));
			space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.ANY, PORTAL, PORTER,	onPortalInteractionBegin));
		}
		
		private function getinfo(portal:Portal, object:Body):PortalInfo {
			var i:PortalInfo;
			var n:int = infos.length;
			while (--n > -1) {
				i = infos[n];
				if ((portal == i.mportal && object == i.master) || (portal == i.sportal && object == i.slave)) return i;
			}
			return null;
		}
		
		private function infolimbo(info:PortalInfo,body:Body):Limbo {
			if (info == null) return null;
			var i:Limbo;
			var n:int = info.limbos.length;
			while (--n > -1) {
				i = info.limbos[n];
				if (i.master == body || i.slave == body) return i;
			}
			return null;
		}
		
		private function onPortalInteractionEnd(callback:InteractionCallback):void {
			var pBody	:Body 		= callback.int1.castShape ? callback.int1.castShape.body : callback.int1.castBody;
			var object	:Body 		= callback.int2.castShape ? callback.int2.castShape.body : callback.int2.castBody;
			var portal	:Portal 	= pBody.userData as Portal;
			var info	:PortalInfo = getinfo(portal, object);
			var limbo	:Limbo 		= infolimbo(info,object);
			var node	:INapeNode;
			
			if ((--limbo.cnt) != 0) return;
			
			var del:Number = object.worldCOM.sub(portal.node.body.localToWorld(portal.position)).dot(portal.node.body.localToRelative(portal.direction));
			if(del <= 0) { // remove object from it's body
				node = object.userData as INapeNode;
				object.shapes.clear();
				if (node) {
					node.setBodyNull();
					container.removeChild(node as Node2D);
					node = null;
				}
				object = null;
			} else {
				if (object == limbo.master) {
					//node 		= limbo.sBody.userData as INapeNode;
					limbo.slave = null;
				} else {
					//node 		= limbo.mBody.userData as INapeNode;
					limbo.master = null;
				}
				//node.setBodyNull();
				//scene.removeChild(node as Node2D);
			}
			
			delfromLimbo(info.limbos, limbo);	
			delfromLimbo(limbos, limbo);
			
			if(info.master.shapes.length==0 || info.slave.shapes.length==0) {
				// delete info
				info.pcon.space = null;
				if (info.master.shapes.length == 0) {
					info.master.space = null;
					node = info.master.userData as INapeNode;
				} else {
					info.slave.space = null;
					node = info.slave.userData as INapeNode;
				}
				container.removeChild(node as Node2D);
				node = null;
				delfrom(infos, info);
			}
		}
		
		private function onPortalInteractionBegin(callback:InteractionCallback):void {
			var arbiters:ArbiterList 	= callback.arbiters;
			var pBody	:Body 			= callback.int1.castShape ? callback.int1.castShape.body : callback.int1.castBody;
			var object	:Body 			= callback.int2.castShape ? callback.int2.castShape.body : callback.int2.castBody;
			var portal	:Portal 		= pBody.userData as Portal;
			if (!portal) return;
			
			var info	:PortalInfo = getinfo(portal, object);
			var limbo	:Limbo 		= infolimbo(info, object);
			if (limbo != null) {
				limbo.cnt++;
				return;
			}
			
			var nortal		:Portal = portal.target;
			var scale		:Number = nortal.width / portal.width;
			var node		:INapeNode;
			var clone		:INapeNode;
			var cloneBody	:Body;
			
			if (info == null) {
				node  		= object.userData as INapeNode;
				clone 		= node.copyAsINapeNode();
				clone.scale(scale, scale);
				clone.body.position.set(node.body.position);
				cloneBody 	= clone.body;
				container.addChild(clone as Node2D);
				
				var pcon:PortalConstraint = new PortalConstraint(
					portal.node.body, portal.position, portal.direction,
					nortal.node.body, nortal.position, nortal.direction,
					scale,
					object,cloneBody
				);
				
				pcon.space = space;
				pcon.set_properties(cloneBody,object);
				
				info = new PortalInfo();
				info.master = object;
				info.mportal = portal;
				info.slave = cloneBody;
				info.sportal = nortal;
				info.pcon = pcon;
				
				var nlimbo:Limbo = new Limbo(); 
				nlimbo.cnt = 1;
				nlimbo.master = object;
				nlimbo.slave = cloneBody;
				
				info.limbos.push(nlimbo);
				nlimbo.info = info;
				
				infos.push(info);
				limbos.push(nlimbo);
				
				object.cbType = INOUT;
				cloneBody.cbType = INOUT;
				
			} else {
				
				cloneBody		= (info.master == object) ? info.slave : info.master;
				
				nlimbo			= new Limbo(); 
				nlimbo.cnt 		= 1;
				nlimbo.master 	= (info.master==object) ? cloneBody : object;
				nlimbo.slave 	= (info.master==object) ? object 	: cloneBody;
				
				info.limbos.push(nlimbo);
				nlimbo.info = info;
				
				limbos.push(nlimbo);
				
				object.cbType 		= INOUT;
				cloneBody.cbType 	= INOUT;
			}
		}
		
		private function onPreCollisionIgnore(cb:PreCallback):PreFlag {
			return PreFlag.IGNORE;
		}
		
		private function onPreCollision(cb:PreCallback):PreFlag {
			var arb	:Arbiter = cb.arbiter;
			var carb:CollisionArbiter = arb.collisionArbiter;
			
			var ret:PreFlag = PreFlag.ACCEPT_ONCE;
			
			if (arb.body1.cbType == INOUT) ret = evalualte(carb.contacts, ret, arb.body1);
			if (arb.body2.cbType == INOUT) ret = evalualte(carb.contacts, ret, arb.body2);
			
			return ret;
		}
		
		private function evalualte(contacts:ContactList, ret:PreFlag, body:Body):PreFlag {
			if(ret==PreFlag.IGNORE_ONCE) return ret;
			var i		:int = 0;
			var j		:int;
			var n		:int;
			var limbo	:Limbo;
			var c		:Contact;
			var rem		:Boolean;
			var info	:PortalInfo;
			var portal	:Portal;
			var del		:Number;
			while (i < contacts.length) {
				c = contacts.at(i);
				rem = false;
				n = limbos.length;
				j = -1;
				while (++j < n) {
					limbo = limbos[j];
					if(limbo.master==body || limbo.slave==body) {
						info 	= limbo.info;
						portal	= (body==info.master) ? info.mportal : info.sportal;
						del 	= c.position.sub(portal.node.body.localToWorld(portal.position)).dot(portal.node.body.localToRelative(portal.direction));
						if (del <= 0) { 
							rem = true;
							break; 
						}
					}
				}
				
				if(rem) {
					contacts.remove(c);
					break;
				} else {
					i++;
				}
			}
			
			if (contacts.length == 0) return PreFlag.IGNORE_ONCE;
			else return ret;
		}
		
		public function dispose():void {
			infos = null;
			limbos = null;
			
			space.listeners.foreach(function(l:InteractionListener):void { space.listeners.remove(l);  } );
			space = null;
		}
		
		
		private static function delfromLimbo(list:Vector.<Limbo>,obj:Limbo):void {
			for (var i:int = 0; i < list.length; i++) {
				if (list[i] === obj) {
					list[i] = list[int(list.length - 1)];
					list.pop();
					break;
				}
			}
		}
		
		private static function delfrom(list:Vector.<PortalInfo>,obj:PortalInfo):void {
			for (var i:int = 0; i < list.length; i++) {
				if (list[i] === obj) {
					list[i] = list[int(list.length - 1)];
					list.pop();
					break;
				}
			}
		}
	}
}