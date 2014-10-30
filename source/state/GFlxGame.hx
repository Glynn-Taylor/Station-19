package state;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;

/**
 * ...
 * @author ...
 */
class GFlxGame extends FlxGame
{

	public function new(GameSizeX:Int=640, GameSizeY:Int=480, ?InitialState:Class<FlxState>, Zoom:Float=1, UpdateFramerate:Int=60, DrawFramerate:Int=60, SkipSplash:Bool=false, StartFullscreen:Bool=false) 
	{
		super(GameSizeX, GameSizeY, InitialState, Zoom, UpdateFramerate, DrawFramerate, SkipSplash, StartFullscreen);
	}
	public function GOnResize() {
		var width:Int = FlxG.stage.stageWidth;
		var height:Int = FlxG.stage.stageHeight;
		
		#if FLX_RENDER_TILE
		FlxG.bitmap.onContext();
		#end
		
		_state.onResize(width, height);
		FlxG.plugins.onResize(width, height);
		FlxG.signals.gameResized.dispatch(width, height);
		
		resizeGame(width, height);
	}
	
}