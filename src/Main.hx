package;

import de.peote.view.PeoteView;
import de.peote.view.displaylist.DisplaylistType;
import haxe.Timer;
import haxe.ui.Toolkit;
import haxe.ui.core.Screen;
import openfl.Lib;
import openfl.display.OpenGLView;
import openfl.display.StageDisplayState;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;

class Main {
	static var view:OpenGLView;
    static var width: Int;
    static var height: Int;
    static var mouse_x: Int = 0;
    static var mouse_y: Int = 0;
    static var zoom: Int = 1;
    static var xOffset: Int = 0;
    static var yOffset: Int = 0;
	
	static var startTime:Float;
	static var peoteView:PeoteView;
	
	// shader uniform vars
	public static var iteration:Array<Dynamic> = [3, 5];
	public static var param:Array<Dynamic> = [1.9, 2.3];
	public static var balance:Array<Dynamic> = [0.5];
	public static var start:Array<Dynamic> = [0.5];
	public static var colpos:Array<Dynamic> = [1.0,0.0,0.0];
	public static var colmid:Array<Dynamic> = [0.0,0.0,0.0];
	public static var colneg:Array<Dynamic> = [0.0,0.0,1.0];
	static var coltype:Array<Dynamic> = [0];
	
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
		Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
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
				w: 4000,
				h: 4000,
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
			peoteView.render(Timer.stamp() - startTime, Std.int (rect.width), Std.int (rect.height), mouse_x, mouse_y, zoom, xOffset, yOffset);
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
	static function onMouseMove (x:Float, y:Float):Void
	{
		//trace("onMouseMove: " + x + "," + y );
		mouse_x = Std.int(x);
		mouse_y = Std.int(y);		
		setOffsets();
	}
	static function onTouchMove (x:Float, y:Float, id:Int):Void
	{
		//trace("onTouchMove: " + x + "," + y );
		mouse_x = Std.int(x);
		mouse_y = Std.int(y);
		setOffsets();
	}
	static function onMouseDown (x:Float, y:Float, button:Int):Void
	{	
		//trace("onMouseDown: x=" + x + " y="+ y);
		//if ( button == 0) zoom++;
		//else if (button == 1 && zoom>1) zoom--;
	}
	static function onMouseUp (x:Float, y:Float, button:Int):Void
	{	
		//trace("onmouseup: "+button+" x=" + x + " y="+ y);
	}
	static function onMouseWheel (deltaX:Float, deltaY:Float):Void
	{	
		//trace("onmousewheel: " + deltaX + ',' + deltaY );
		if ( deltaY>0 ) zoom++;
		else if (zoom > 1) zoom--;
		setOffsets();
	}
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
	// end Event Handler ------------------------------
	// ------------------------------------------------------------
	
	static function setOffsets():Void {
		xOffset = Std.int( - width*(zoom-1)/zoom * mouse_x/width);
		yOffset = Std.int( - height*(zoom-1)/zoom * mouse_y/height);
	}

}
