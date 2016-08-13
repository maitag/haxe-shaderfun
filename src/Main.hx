package;

import haxe.Timer;
import haxe.ui.components.HSlider;
import haxe.ui.components.VSlider;
import haxe.ui.components.Label;
import haxe.ui.containers.VBox;

import openfl.Lib;
import openfl.display.StageDisplayState;
import openfl.display.OpenGLView;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import openfl.geom.Rectangle;


import haxe.ui.Toolkit;
import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.core.UIEvent;
import haxe.ui.util.Variant;
import haxe.ui.macros.ComponentMacros;

import de.peote.view.PeoteView;
import de.peote.view.displaylist.DisplaylistType;

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
	static var iteration:Array<Dynamic> = [3, 5];
	static var param:Array<Dynamic> = [1.9, 2.3];
	static var balance:Array<Dynamic> = [0.5];
	static var start:Array<Dynamic> = [0.5];
	static var colpos:Array<Dynamic> = [1.0,0.0,0.0];
	static var colmid:Array<Dynamic> = [0.0,0.0,0.0];
	static var colneg:Array<Dynamic> = [0.0,0.0,1.0];
	static var coltype:Array<Dynamic> = [0];
	
    public static function main() {
        initPeoteView();
		
		Toolkit.init();

        var main:Component = ComponentMacros.buildComponent("assets/ui/main.xml");

        /*
         * We are using 'Screen.instance.addComponent' as its more cross framework,
         * however, would could have also used 'Lib.current.stage.addChild'
         */
		
        Screen.instance.addComponent(main);

		//var box:VBox = main.findComponent("items", null, true);
		
		var slider1:HSlider = main.findComponent("iteration0", null, true);
		var slider2:HSlider = main.findComponent("iteration1", null, true);
		var slider3:HSlider = main.findComponent("param0", null, true);
		var slider4:HSlider = main.findComponent("param1", null, true);
		var slider5:HSlider = main.findComponent("balance", null, true);
		var slider6:HSlider = main.findComponent("start", null, true);		
		var slider7:VSlider = main.findComponent("r1", null, true); // take care not using HSlider type (crash on cpp)
		var slider8:VSlider = main.findComponent("g1", null, true);
		var slider9:VSlider = main.findComponent("b1", null, true);
		var slider10:VSlider = main.findComponent("r2", null, true);
		var slider11:VSlider = main.findComponent("g2", null, true);
		var slider12:VSlider = main.findComponent("b2", null, true);
		var slider13:VSlider = main.findComponent("r3", null, true);
		var slider14:VSlider = main.findComponent("g3", null, true);
		var slider15:VSlider = main.findComponent("b3", null, true);

		var slider1t:Label = main.findComponent("iteration0t", null, true);
		var slider2t:Label = main.findComponent("iteration1t", null, true);
		var slider3t:Label = main.findComponent("param0t", null, true);
		var slider4t:Label = main.findComponent("param1t", null, true);
		var slider5t:Label = main.findComponent("balancet", null, true);
		var slider6t:Label = main.findComponent("startt", null, true);
		

		slider1.onChange = function(e) { iteration[0] = Std.parseFloat(slider1.value); slider1t.text = slider1.value;}
		slider2.onChange = function(e) { iteration[1] = Std.parseFloat(slider2.value); slider2t.text = slider2.value;}
		slider3.onChange = function(e) { param[0]     = Std.parseFloat(slider3.value); slider3t.text = slider3.value;}
		slider4.onChange = function(e) { param[1]     = Std.parseFloat(slider4.value); slider4t.text = slider4.value;}
		slider5.onChange = function(e) { balance[0]   = Std.parseFloat(slider5.value); slider5t.text = slider5.value;}
		slider6.onChange = function(e) { start[0]     = Std.parseFloat(slider6.value); slider6t.text = slider6.value;}
		slider7.onChange = function(e) { colpos[0]    = Std.parseFloat(slider7.value); }
		slider8.onChange = function(e) { colpos[1]    = Std.parseFloat(slider8.value); }
		slider9.onChange = function(e) { colpos[2]    = Std.parseFloat(slider9.value); }
		slider10.onChange = function(e) { colmid[0]   = Std.parseFloat(slider10.value); }
		slider11.onChange = function(e) { colmid[1]   = Std.parseFloat(slider11.value); }
		slider12.onChange = function(e) { colmid[2]   = Std.parseFloat(slider12.value); }
		slider13.onChange = function(e) { colneg[0]   = Std.parseFloat(slider13.value); }
		slider14.onChange = function(e) { colneg[1]   = Std.parseFloat(slider14.value); }
		slider15.onChange = function(e) { colneg[2]   = Std.parseFloat(slider15.value); }

		slider1.dispatch(new UIEvent(UIEvent.CHANGE));
		slider2.dispatch(new UIEvent(UIEvent.CHANGE));
		slider3.dispatch(new UIEvent(UIEvent.CHANGE));
		slider4.dispatch(new UIEvent(UIEvent.CHANGE));
		slider5.dispatch(new UIEvent(UIEvent.CHANGE));
		slider6.dispatch(new UIEvent(UIEvent.CHANGE));
		slider7.dispatch(new UIEvent(UIEvent.CHANGE));
		slider8.dispatch(new UIEvent(UIEvent.CHANGE));
		slider9.dispatch(new UIEvent(UIEvent.CHANGE));
		slider10.dispatch(new UIEvent(UIEvent.CHANGE));
		slider11.dispatch(new UIEvent(UIEvent.CHANGE));
		slider12.dispatch(new UIEvent(UIEvent.CHANGE));
		slider13.dispatch(new UIEvent(UIEvent.CHANGE));
		slider14.dispatch(new UIEvent(UIEvent.CHANGE));
		slider15.dispatch(new UIEvent(UIEvent.CHANGE));
		

		var button:Button = main.findComponent("random", null, true);
        button.onClick = function(e) {
            slider1.pos = Math.random() * slider1.max;
            slider2.pos = Math.random() * slider2.max;
            slider3.pos = Math.random() * slider3.max + 1;
			slider4.pos = Math.random() * slider4.max;
			slider5.pos = Math.random() * slider5.max;
			slider6.pos = Math.random() * slider6.max;
        }

		

		
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
