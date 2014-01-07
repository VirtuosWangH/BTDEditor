package editor.events
{
	import flash.events.Event;
	
	public class CommonEvent extends Event
	{
		public static const CHANGE_NAME:String = "Change Name";
		public static const CHANGE_DENSITY:String = "Change Density";
		
		public static const START_CREATE:String = "Start Create"
		public function CommonEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}