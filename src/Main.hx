package;

import peote.view.PeoteView;
import peote.view.displaylist.DisplaylistType;
import haxe.Timer;
import haxe.ui.Toolkit;
import haxe.ui.core.Screen;
import openfl.Lib;
import openfl.display.OpenGLView;
import openfl.display.StageDisplayState;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;

class Main {
	static var view:OpenGLView;
	static var width: Int;
	static var height: Int;
	static var mouse_x: Float = 0;
	static var mouse_y: Float = 0;
	static var dragstart_x: Float = 0;
	static var dragstart_y: Float = 0;
	static var dragmode: Bool = false;
	static var zoom: Float = 1.0;
	static var zoomstep: Float = 1.2;

	static var startTime:Float;
	static var peoteView:PeoteView;

	// shader uniform vars
	static var position:Array<Float> = [0, 0];
	static var scale:Array<Float> = [400, 400];
	static var coltype:Array<Float> = [0];

	public static var iteration:Array<Float> = [3, 5];
	public static var param:Array<Float> = [1.9, 2.3];
	public static var balance:Array<Float> = [0.5];
	public static var start:Array<Float> = [0.5];
	public static var colpos:Array<Float> = [1,0,0];
	public static var colmid:Array<Float> = [0,0,0];
	public static var colneg:Array<Float> = [0,0,1];


	public static function main() {
		initPeoteView();

		Toolkit.init();

		var ui:UI = new UI();
		Screen.instance.addComponent(ui);
		// stage events -----------------------------------------
		Lib.current.stage.addEventListener( Event.RESIZE, function(e) { onWindowResize( Lib.current.stage.stageWidth, Lib.current.stage.stageHeight );  } );
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_MOVE, function(e:MouseEvent) { onMouseMove( e.stageX, e.stageY );  } );
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_DOWN, function(e:MouseEvent) { onMouseDown( e.stageX, e.stageY, 0 );  } );
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_UP,   function(e:MouseEvent) { onMouseUp( e.stageX, e.stageY, 0 );  } );
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_WHEEL,function(e:MouseEvent) { onMouseWheel( e.delta, e.delta );  } );
		/*Lib.current.stage.addEventListener( TouchEvent.TOUCH_BEGIN, onTouchBegin);
		Lib.current.stage.addEventListener( TouchEvent.TOUCH_END,   onTouchEnd  );
		Lib.current.stage.addEventListener( TouchEvent.TOUCH_MOVE,  onTouchMove );*/
		Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown   );
	}

	
	
	static function initPeoteView () {
		if (OpenGLView.isSupported) {

			trace("OpenGLView.isSupported");
			
			// start Sample
			startTime = Timer.stamp();
			var t:Float = Timer.stamp() - startTime;
			
			peoteView = new PeoteView({});

			peoteView.setProgram( {
				program:0,
				fshader: "shader/lyapunov.frag",
				vars: [
					"uPosition" => position,
					"uScale" => scale,
					"uIteration" => iteration,
					"uParam" => param,
					"uBalance"=> balance,
					"uStart"=> start,
					"uColpos"=> colpos,
					"uColmid"=> colmid,
					"uColneg"=> colneg,
					"uColtype"=> coltype,
				]
			});
			
			peoteView.setDisplaylist( { 
				displaylist:0,
				type:DisplaylistType.SIMPLE,
				maxElements:       1,
				maxPrograms:       1,
				bufferSegments:    1,
				x:0,
				y:0,
			});
			
			peoteView.setElement( { 
				element:0,
				displaylist:0,
				program:0,
				x: 0,
				y: 0,
				w: 2000,
				h: 2000
			});
			

			// ---------------------------------------------------------------
			
			view = new OpenGLView ();
			view.render = renderView;
			Lib.current.stage.addChild(view);
		}
	}
	static var frame:Int = 0;
	// ----------- Render Loop ------------------------------------
	static function renderView (rect:Rectangle):Void
	{
		peoteView.render(Timer.stamp() - startTime, Std.int (rect.width), Std.int (rect.height), Std.int(mouse_x), Std.int(mouse_y), 1);
	}


	
	// ------------------------------------------------------------
	// ----------- EVENT HANDLER ----------------------------------
	static function onWindowResize (w:Int, h:Int):Void
	{
		width = w;
		height = h;
		
		var ui = Screen.instance.rootComponents[0];
		ui.left = w - ui.width;
	}

	
	// Mouse Events ---------------------------------------------

	static function onMouseDown (x:Float, y:Float, button:Int):Void
	{	
		//trace("onMouseDown: x=" + x + " y="+ y);
		if ( button == 0)
		{
			dragstart_x = position[0] - x;
			dragstart_y = position[1] - y;
			dragmode = true;
		}
		//else if (button == 1) {}
	}
	
	static function onMouseUp (x:Float, y:Float, button:Int):Void
	{	
		//trace("onmouseup: "+button+" x=" + x + " y="+ y);
		dragmode = false;
	}
	
	static function onMouseMove (x:Float, y:Float):Void
	{
		//trace("onMouseMove: " + x + "," + y );
		mouse_x = x;
		mouse_y = y;		
		if (dragmode)
		{
			position[0] = (dragstart_x + mouse_x);
			position[1] = (dragstart_y + mouse_y);
		}
	}
	
	static function onMouseWheel (deltaX:Float, deltaY:Float):Void
	{	
		//trace("onmousewheel: " + deltaX + ',' + deltaY );
		if ( deltaY > 0 )
		{
			if (zoom < 10000)
			{
				position[0] -= zoomstep * (mouse_x - position[0]) - (mouse_x - position[0]);
				position[1] -= zoomstep * (mouse_y - position[1]) - (mouse_y - position[1]);
				zoom *= zoomstep;
			}
		}
		else if ( zoom > 0.03 )
		{
			position[0] -= (mouse_x - position[0]) / zoomstep - (mouse_x - position[0]);
			position[1] -= (mouse_y - position[1]) / zoomstep - (mouse_y - position[1]);
			zoom /= zoomstep;
		}
		scale[0] = scale[1] =  zoom*400.0;
	}
	
	// Touch Events --------------------------------------------- TODO
	/*
	static function onTouchBegin (e:TouchEvent):Void
	{
		trace("onTouchBegin: " + e );
		//e.localX
		//e.localY
		//e.touchPointID
	}
	static function onTouchEnd (e:TouchEvent):Void
	{
		trace("onTouchEnd: " + e );
	}
	static function onTouchMove (e:TouchEvent):Void
	{
		trace("onTouchMove: " + e );
	}
	*/
	
	// Keyboard Events -------------------------------------------
	
	static function onKeyDown (k:KeyboardEvent):Void
	{
		switch (k.keyCode) {
			case Keyboard.F:
				trace("SET FULLSCREEN");
				#if html5				
				var e:Dynamic = untyped __js__("document.getElementById('openfl-content').getElementsByTagName('canvas')[0]");
				var noFullscreen:Dynamic = untyped __js__("(!document.fullscreenElement && !document.mozFullScreenElement && !document.webkitFullscreenElement && !document.msFullscreenElement)");
				
				if ( noFullscreen)
				{	// enter fullscreen
					if (e.requestFullScreen) e.requestFullScreen();
					else if (e.msRequestFullScreen) e.msRequestFullScreen();
					else if (e.mozRequestFullScreen) e.mozRequestFullScreen();
					else if (e.webkitRequestFullScreen) e.webkitRequestFullScreen();
				}
				else
				{	// leave fullscreen
					var d:Dynamic = untyped __js__("document");
					if (d.exitFullscreen) d.exitFullscreen();
					else if (d.msExitFullscreen) d.msExitFullscreen();
					else if (d.mozCancelFullScreen) d.mozCancelFullScreen();
					else if (d.webkitExitFullscreen) d.webkitExitFullscreen();					
				}
				#else
				if(Lib.current.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE)
					 Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				else Lib.current.stage.displayState = StageDisplayState.NORMAL;
				#end				
							
			default:
		}
	}
	// end Event Handler
	// ------------------------------------------------------------

}
