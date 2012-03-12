package mikedotalmond.napoleon.constraints.portal {
	
	import nape.phys.Body;
	
	final public class Limbo {
		
		public var master:Body; //master
		public var slave:Body; //slave
		
		public var cnt	:int;
		public var info	:PortalInfo;
		
		public function Limbo() {
			cnt = 0;
		}
	}
}