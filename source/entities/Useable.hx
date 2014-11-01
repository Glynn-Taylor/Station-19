package entities;

import flixel.FlxSprite;
import player.Player;

/**
 * ...
 * @author ApexRUI
 * Abstract base class for objects that can be used by the player to trigger another object (e.g. button->door)
 */
class Useable extends FlxSprite
{
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y);
		
	}
	//No abstract function in haxe, must override instead
	public function interact(_player:Player,_triggerMap:Map<Int,Triggerable>) {
		
	}
	
}