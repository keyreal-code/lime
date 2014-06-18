package lime.ui;


import lime.app.Event;
import lime.system.System;

#if js
import js.Browser;
#elseif flash
import flash.Lib;
#end


@:allow(lime.ui.Window)
class MouseEventManager {
	
	
	public static var onMouseDown = new Event<Float->Float->Int->Void> ();
	public static var onMouseMove = new Event<Float->Float->Int->Void> ();
	public static var onMouseUp = new Event<Float->Float->Int->Void> ();
	
	private static var instance:MouseEventManager;
	private var eventInfo:MouseEventInfo;
	
	
	public function new () {
		
		instance = this;
		eventInfo = new MouseEventInfo ();
		
		#if (cpp || neko)
		lime_mouse_event_manager_register (dispatch, eventInfo);
		#end
		
	}
	
	
	private function dispatch ():Void {
		
		switch (eventInfo.type) {
			
			case MOUSE_DOWN:
				
				onMouseDown.dispatch (eventInfo.x, eventInfo.y, cast eventInfo.button);
			
			case MOUSE_UP:
				
				onMouseUp.dispatch (eventInfo.x, eventInfo.y, cast eventInfo.button);
			
			case MOUSE_MOVE:
				
				onMouseMove.dispatch (eventInfo.x, eventInfo.y, cast eventInfo.button);
			
			default:
			
		}
		
	}
	
	
	#if js
	private function handleDOMEvent (event:js.html.MouseEvent):Void {
		
		/*
		var rect;
		
		if (__canvas != null) {
			
			rect = __canvas.getBoundingClientRect ();
			__mouseX = (event.clientX - rect.left) * (stageWidth / rect.width);
			__mouseY = (event.clientY - rect.top) * (stageHeight / rect.height);
			
		} else {
			
			rect = __div.getBoundingClientRect ();
			//__mouseX = (event.clientX - rect.left) * (__div.style.width / rect.width);
			__mouseX = (event.clientX - rect.left);
			//__mouseY = (event.clientY - rect.top) * (__div.style.height / rect.height);
			__mouseY = (event.clientY - rect.top);
			
		}
		*/
		
		eventInfo.x = event.clientX;
		eventInfo.y = event.clientY;
		
		eventInfo.type = switch (event.type) {
			
			case "mousedown": MOUSE_DOWN;
			case "mouseup": MOUSE_UP;
			case "mousemove": MOUSE_MOVE;
			//case "click": MouseEvent.CLICK;
			//case "dblclick": MouseEvent.DOUBLE_CLICK;
			case "mousewheel": MOUSE_WHEEL;
			default: null;
			
		}
		
		dispatch ();
		
	}
	#end
	
	
	#if flash
	private function handleFlashEvent (event:flash.events.MouseEvent):Void {
		
		eventInfo.x = event.stageX;
		eventInfo.y = event.stageY;
		
		eventInfo.type = switch (event.type) {
			
			case flash.events.MouseEvent.MOUSE_DOWN: MOUSE_DOWN;
			case flash.events.MouseEvent.MOUSE_MOVE: MOUSE_MOVE;
			default: MOUSE_UP;
			
		}
		
		dispatch ();
		
	}
	#end
	
	
	private static function registerWindow (window:Window):Void {
		
		if (instance != null) {
			
			#if js
			window.element.addEventListener ("mousedown", instance.handleDOMEvent, true);
			window.element.addEventListener ("mousemove", instance.handleDOMEvent, true);
			window.element.addEventListener ("mouseup", instance.handleDOMEvent, true);
			//window.element.addEventListener ("mousewheel", handleDOMEvent, true);
			
			// Disable image drag on Firefox
			/*Browser.document.addEventListener ("dragstart", function (e) {
				if (e.target.nodeName.toLowerCase() == "img") {
					e.preventDefault();
					return false;
				}
				return true;
			}, false);*/
			#elseif flash
			Lib.current.stage.addEventListener (flash.events.MouseEvent.MOUSE_DOWN, instance.handleFlashEvent);
			Lib.current.stage.addEventListener (flash.events.MouseEvent.MOUSE_MOVE, instance.handleFlashEvent);
			Lib.current.stage.addEventListener (flash.events.MouseEvent.MOUSE_UP, instance.handleFlashEvent);
			#end
			
		}
		
	}
	
	
	#if (cpp || neko)
	private static var lime_mouse_event_manager_register = System.load ("lime", "lime_mouse_event_manager_register", 2);
	#end
	
	
}


private class MouseEventInfo {
	
	
	public var button:MouseEventButton;
	public var type:MouseEventType;
	public var x:Float;
	public var y:Float;
	
	
	
	public function new (type:MouseEventType = null, x:Float = 0, y:Float = 0, button:MouseEventButton = null) {
		
		this.type = type;
		this.x = x;
		this.y = y;
		this.button = button;
		
	}
	
	
	public function clone ():MouseEventInfo {
		
		return new MouseEventInfo (type, x, y, button);
		
	}
	
	
}


@:enum private abstract MouseEventButton(Int) {
	
	var MOUSE_BUTTON_LEFT = 0;
	var MOUSE_BUTTON_MIDDLE = 1;
	var MOUSE_BUTTON_RIGHT = 2;
	
}


@:enum private abstract MouseEventType(Int) {
	
	var MOUSE_DOWN = 0;
	var MOUSE_UP = 1;
	var MOUSE_MOVE = 2;
	var MOUSE_WHEEL = 3;
	
}