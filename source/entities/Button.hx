package entities;
import flixel.FlxSprite;
import player.Player;
import util.FileReg;

/**
 * ...
 * @author ApexRUI
 */
class Button extends Useable
{
	private var _id:Int;
	
	public function new(x:Int,y:Int,id:Int) 
	{
		super(x, y);
		_id = id;
		loadGraphic(FileReg.imgEntButton, false, 16, 32);
	}
	
	override public function interact(_player:Player,_triggerMap:Map<Int,Triggerable>) {
		_triggerMap.get(_id).Trigger(_player);
	}
}