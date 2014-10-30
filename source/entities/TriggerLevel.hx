package entities;
import flixel.FlxSprite;

/**
 * ...
 * @author ...
 */
class TriggerLevel extends FlxSprite
{
	public var _id:Int;
	public function new(x:Int,y:Int,w:Float,h:Float,id:Int) 
	{
		super(x, y);
		width = w;
		height = h;
		makeGraphic(Std.int(width), Std.int(height), 0x00FFFFFF, false);
		_id = id;
	}
	
}