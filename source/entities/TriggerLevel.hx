package entities;
import flixel.FlxSprite;

/**
 * @author Glynn Taylo
 * Sprite that loads a new level when player enters collider (handled elsewhere as only 1 per level currently)
 * Needs work if game design changes; currently designed for each level to be linear
 */
class TriggerLevel extends FlxSprite
{
	public var _id:Int;					//ID of level
	//CONSTRUCTOR
	public function new(x:Int,y:Int,w:Float,h:Float,id:Int) 
	{
		super(x, y);
		width = w;
		height = h;
		makeGraphic(Std.int(width), Std.int(height), 0x00FFFFFF, false);//Make transparent graphic
		_id = id;
	}
	
}