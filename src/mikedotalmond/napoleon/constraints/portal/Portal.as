package mikedotalmond.napoleon.constraints.portal {

	import flash.geom.Rectangle;
	import mikedotalmond.napoleon.INapeNode;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.shape.Polygon;
	import nape.shape.Shape;

	final public class Portal {
		//bound body
		public var node		:INapeNode;
		public var body		:Body;
		
		//local coordiantes
		public var position :Vec2;
		public var direction:Vec2;

		// linked portal
		public var target	:Portal;
		public var width	:Number;
		
		public function Portal(node:INapeNode, direction:Vec2, width:Number, height:Number) {
			this.node 			= node;
			this.body 			= node.body;
			this.position 		= body.localCOM.add(new Vec2(width / 2.1, 0))
			this.direction 		= direction;
			this.width 			= height;
			node.body.userData 	= this;
			node.body.shapes.foreach(function(s:Shape):void {
				s.cbType = PortalManager.PORTAL;
				s.filter = new InteractionFilter( -1, -1, -1, -1, -1, -1);
			});
			
		}
	}
}