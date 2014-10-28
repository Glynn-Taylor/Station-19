package entities;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import player.Player;
import util.FileReg;

/**
 * ...
 * @author ApexRUI
 */
class Button extends Useable
{
	private var _id:Int;
	private var _canBePressed:Bool = true;
	
	public function new(x:Int,y:Int,id:Int) 
	{
		super(x, y);
		_id = id;
		loadGraphic(FileReg.imgEntButton, false, 16, 32);
	}
	
	override public function interact(_player:Player, _triggerMap:Map<Int,Triggerable>) {
		if(_canBePressed){
			FlxG.log.add("button triggered id: " + Std.string(_id));
			_triggerMap.get(_id).Trigger(_player);
			new FlxTimer(1, canBePressedAgain, 1);
			FlxG.sound.play(FileReg.sndSelect, 1, false);
			_canBePressed =false;
		}
	}
	
	private function canBePressedAgain(Timer:FlxTimer):Void
	{
		_canBePressed = true;
	}
}