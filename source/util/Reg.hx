package util ;

import flixel.FlxG;
import flixel.util.FlxSave;
import openfl.display.BitmapData;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
	/**
	 * Generic levels Array that can be used for cross-state stuff.
	 * Example usage: Storing the levels of a platformer.
	 */
	public static var levels:Array<Dynamic> = [];
	public static var level:Int = 0;

	public static var saves:Array<FlxSave> = [];
	public static var playerPixels:BitmapData;
	public static inline var MENU_WIDTH:Int = 480;
	public static inline var MENU_HEIGHT:Int = 320;
	
	public static inline var GAME_WIDTH:Int = 300;
	public static inline var GAME_HEIGHT:Int = 200;
	public static inline var TEXT_COLOR:Int = 0xFFBAFC19;
	
	
}