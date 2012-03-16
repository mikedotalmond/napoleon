package mikedotalmond.napoleon.constraints.portal {

	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Polygon2D;
	import de.nulldesign.nd2d.display.Quad2D;
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
			
			body.userData 	= this;
			body.shapes.foreach(function(s:Shape):void {
				s.cbType = PortalManager.PORTAL;
				s.filter = new InteractionFilter( -1, -1, -1, -1, -1, -1);
			});
			
			// add a boundry so objects can't fly through from the back
			body.shapes.add(new Polygon(Polygon.rect( -(width * 7.1) - position.x	,(-height / 2) - 1, 
														width * 7.1					, height + 2
													), null, new InteractionFilter( -1, -1, -1, -1, -1, -1), PortalManager.OBJECT));
			
			// l+r side walls to stop stuff exiting at the edges (for objects exiting at angles near to 90 degrees to the portal)
			/*body.shapes.add(new Polygon(Polygon.rect(  (-width * 6),	(height / 2) - 2, 
														width * 7, 					8
													), null, null));
			
			body.shapes.add(new Polygon(Polygon.rect(  (-width * 6),	(-height / 2) - 2, 
														width * 7, 					8
													), null, null));
			*/
			
			var nd:Quad2D = new Quad2D(width * 7, height + 4);
			nd.linearGradient(0, 0x00ff00, 1, 1, true);
			nd.x = (-width * 4);
			(node as Node2D).addChild(nd);
		}
		
		public function dispose():void {
			position 	= null;
			direction 	= null;
			if(node) node.setBodyNull();
			node = null;
			target = null;
		}
	}
}