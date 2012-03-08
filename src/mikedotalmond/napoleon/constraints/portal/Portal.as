package mikedotalmond.napoleon.constraints.portal {

	import mikedotalmond.napoleon.INapeNode;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.shape.Shape;

	final public class Portal {
		//bound body
		public var node		:INapeNode;
		public var body		:Body;
		
		//local coordiantes
		public var position :Vec2;
		public var direction:Vec2;

		//linked portal
		public var target	:Portal;
		public var width	:Number;
		
		public function Portal(node:INapeNode, position:Vec2, direction:Vec2, width:Number) {
			this.node 		= node;
			this.body 		= node.body;
			this.position 	= position;
			this.direction 	= direction;
			this.width 		= width;
			node.body.cbType = PortalManager.PORTAL;
			node.body.setShapeFilters(new InteractionFilter(-1,-1,-1,-1,-1,-1));
			node.body.userData = this;
		}
	}
}