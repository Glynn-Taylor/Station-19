package entities;
import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * ...
 * @author ApexRUI
 * Abstract base class for objects that have a use that can be activated by an external force (e.g. a button->door)
 */
class Triggerable extends FlxSprite
{
	public var _causeType:String = "player";	//Default type to player
	public function new(x:Float,y:Float) 
	{
		super(x, y);
	}
	//No abstract function in haxe, must override instead
	public function Trigger(cause:FlxObject) {
		
    }
}