package  ;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.util.FlxSave;
import state.GFlxGame;
import state.MenuState;
import util.FileReg;

class Main extends Sprite 
{
	var gameWidth:Int = 400; 					// Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 300; 					// Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = MenuState; // The FlxState the game starts with.
	var zoom:Float = 1; 						// If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; 					// How many frames per second the game should run at.
	var skipSplash:Bool = true; 				// Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; 			// Whether to start the game in fullscreen on desktop targets
	
	// Everything below is boilerplate, except loading savedata and playing music in setupGame()
	
	public static function main():Void
	{	
		Lib.current.addChild(new Main());
	}
	
	public function new() 
	{
		super();
		
		if (stage != null) 
		{
			init();
		}
		else 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}
	
	private function init(?E:Event):Void 
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		setupGame();
	}
	
	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		addChild(new GFlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
		
		//Load save data
		if (FlxG.save.data.volume!= null)
		{
			FlxG.sound.volume = FlxG.save.data.volume;	//Load volume setting
		}
		
		FlxG.sound.playMusic(FileReg.mscBG, 1, true);
		FlxG.sound.playMusic(FileReg.mscBG2, 1, true);
		#if (flash) flash.Lib.current.stage.quality = flash.display.StageQuality.LOW; #end
	}
}