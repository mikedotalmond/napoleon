package mikedotalmond.napoleon.constraints.portal {
	
	import nape.phys.Body;

	final public class PortalInfo {
		//source body
		public var master	:Body;
		public var mportal	:Portal;

		//destination body
		public var slave 	:Body;
		public var sportal	:Portal;

		//all shapes in limbo intersecting exit shape
		public var limbos	:Vector.<Limbo>;
		public var pcon		:PortalConstraint;
		
		public function PortalInfo() {
			limbos = new Vector.<Limbo>();
		}
	}
}