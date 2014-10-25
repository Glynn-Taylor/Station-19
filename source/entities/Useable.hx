package entities;

import flixel.FlxSprite;
import player.Player;

/**
 * ...
 * @author ApexRUI
 */
class Useable extends FlxSprite
{

	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y);
		
	}
	
	public function interact(_player:Player,_triggerMap:Map<Int,Triggerable>) {
		
	}
	
}