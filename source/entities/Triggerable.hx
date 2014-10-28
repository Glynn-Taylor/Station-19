package entities;
import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * ...
 * @author ApexRUI
 */
class Triggerable extends FlxSprite
{
	public var _causeType:String = "player";
	public function new(x:Float,y:Float) 
	{
		super(x, y);
	}
	public function Trigger(cause:FlxObject) {
		
    }
}