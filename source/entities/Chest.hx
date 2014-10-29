package entities;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;
import player.Player;
import util.FileReg;
/**
 * ...
 * @author ApexRUI
 */
class Chest extends Useable
{
	private var _amount:Int;
	private var _canBeOpened:Bool = true;
	
	public function new(x:Int,y:Int,amount:Int) 
	{
		super(x, y);
		_amount = amount;
		loadGraphic(FileReg.imgChest, false, 16, 16);
		animation.add("open", [0, 1, 2], 4, false);
	}
	
	override public function interact(_player:Player, _triggerMap:Map<Int,Triggerable>) {
		if(_canBeOpened){
			FlxG.sound.play(FileReg.sndButton, 1, false);
			_player.addAmmo(_amount);
			_canBeOpened = false;
			animation.play("open");
		}
	}
	override public function update():Void 
	{
		if (!animation.finished) {
			animation.play("open");
		}
		super.update();
	}
	
}