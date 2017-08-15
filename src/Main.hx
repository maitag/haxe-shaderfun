package;

import haxe.io.BytesInput;
import haxe.io.BytesOutput;

#if html5
import js.Boot;
import js.Browser;
#end

import haxe.Timer;
import haxe.io.Bytes;
import haxe.crypto.Base64;

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

import peote.view.PeoteView;
import peote.view.displaylist.DisplaylistType;


class Main {
	static var view:OpenGLView;
	static var width:Int;
	static var height:Int;
	static var mouse_x:Float = 0;
	static var mouse_y:Float = 0;
	static var dragstart_x:Float = 0;
	static var dragstart_y:Float = 0;
	public static var dragmode:Bool = false;
	public static var uiIsdragging:Bool = false;
	public static var changed:Bool = false;
	static var zoom:Float = 1.0;
	static var zoomstep:Float = 1.2;
	
	static var peoteView:PeoteView;
	static var frame:Int = 0;

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
	
	static var ui:UI;

	public static function main()
	{
		initPeoteView();

		Toolkit.init();

		ui = new UI();
		Screen.instance.addComponent(ui);
		// stage events -----------------------------------------
		Lib.current.stage.addEventListener( Event.RESIZE, function(e) { onWindowResize( Lib.current.stage.stageWidth, Lib.current.stage.stageHeight );  } );

		// mouse or touch events depends on "first click"
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_UP,   onMouseUp );

		Lib.current.stage.addEventListener( TouchEvent.TOUCH_BEGIN, firstTouchBeginEvent );
		
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
		Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown   );
		
		// stop dragging if mouse leaves app-window
		Lib.current.stage.addEventListener( Event.MOUSE_LEAVE, function(e:MouseEvent) {
			stopDrag();
			ui.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
		});

		getUrlParams();		
	}

	static function firstTouchBeginEvent(e:TouchEvent):Void
	{
		Lib.current.stage.removeEventListener( TouchEvent.TOUCH_BEGIN, firstTouchBeginEvent);
		Lib.current.stage.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		Lib.current.stage.removeEventListener( MouseEvent.MOUSE_UP,   onMouseUp );

		Lib.current.stage.addEventListener( TouchEvent.TOUCH_BEGIN, onTouchBegin );
		Lib.current.stage.addEventListener( TouchEvent.TOUCH_MOVE,  onTouchMove );
		Lib.current.stage.addEventListener( TouchEvent.TOUCH_END,   onTouchEnd );
		
		onTouchBegin(e);
	}	
	
	static function initPeoteView ()
	{
		if (OpenGLView.isSupported) {

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
				maxElements:1,
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
	
	// ----------- Render Loop ------------------------------------
	static function renderView (rect:Rectangle):Void
	{
		peoteView.render( Std.int(rect.width), Std.int(rect.height) );
	}

	// ----------- URL handling ------------------------------------
	static public function updateUrlParams()
	{		
		#if html5
		var b:BytesOutput = ui.serializeParams();
		b.writeFloat(position[0]);
		b.writeFloat(position[1]);
		b.writeFloat(zoom);
		var params:String = Base64.encode(b.getBytes(),false);
		Browser.window.history.replaceState('haxeshaderfun', 'haxeshaderfun', Browser.location.pathname + '?' + params);
		#end
	}
	
	static function getUrlParams()
	{
		#if html5
		var e:EReg = new EReg("\\?([" + Base64.CHARS + "]+)$", "");
		if (e.match(Browser.document.URL)) {
			var b:BytesInput = new BytesInput(Base64.decode( e.matched(1) , false));
			if (b.length == 33) {
				ui.unSerializeParams(b);
				position[0] = b.readFloat();
				position[1] = b.readFloat();
				zoom = b.readFloat();
				scale[0] = scale[1] =  zoom * 400.0;
			}
		}
		#end		
		ui.updateAll();
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

	static function onMouseDown (e:MouseEvent):Void
	{	
		if ( e.buttonDown ) startDrag(e.stageX, e.stageY);
	}
	
	static function onMouseUp (e:MouseEvent):Void
	{	
		stopDrag();
	}
	
	static function onMouseMove (e:MouseEvent):Void
	{
		moveDrag(e.stageX, e.stageY);
	}
	
	static function onMouseWheel (e:MouseEvent):Void
	{	
		if ( e.delta > 0 )
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
		
		scale[0] = scale[1] =  zoom * 400.0;
		
		updateUrlParams();
	}
	
	// Touch Events ---------------------------------------------
	static function onTouchBegin (e:TouchEvent):Void
	{
		startDrag(e.stageX, e.stageY);
	}
	
	static function onTouchMove (e:MouseEvent):Void
	{
		moveDrag(e.stageX, e.stageY);
	}
	
	static function onTouchEnd (e:TouchEvent):Void
	{
		stopDrag();
	}
	
	// Dragging --------------------------------------------------
	static inline function startDrag(x:Float, y:Float)
	{
		dragstart_x = position[0] - x;
		dragstart_y = position[1] - y;
		dragmode = true;		
	}
	
	static inline function stopDrag()
	{
		dragmode = false;
		uiIsdragging = false;
		if (changed) {
			changed = false;
			updateUrlParams();
		}
	}
	
	static inline function moveDrag(x:Float, y:Float)
	{
		mouse_x = x;
		mouse_y = y;		
		if (dragmode && !uiIsdragging)
		{
			position[0] = (dragstart_x + mouse_x);
			position[1] = (dragstart_y + mouse_y);
			changed = true;
		}
	}
	
	// Keyboard Events -------------------------------------------
	
	static function onKeyDown (k:KeyboardEvent):Void
	{
		switch (k.keyCode) {
			case Keyboard.F:
				#if html5				
				var e:Dynamic = Browser.document.getElementById('openfl-content').getElementsByTagName('canvas')[0];
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
					var d:Dynamic = Browser.document;
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
	// ------------------------------------------------------------

}
