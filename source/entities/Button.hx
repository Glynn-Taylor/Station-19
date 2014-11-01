package entities;
import flixel.FlxG;
import flixel.util.FlxTimer;
import player.Player;
import util.FileReg;

/**
 * @author ApexRUI
 * A pressable button entity that can be pressed multiple times after a short delay
 */
class Button extends Useable
{
	private var _id:Int;						//ID of associated triggerable objects (e.g. door, elevator)
	private var _canBePressed:Bool = true;		//Bool to prevent continuous triggering
	private static inline var TIME_TO_BE_PRESSED_AGAIN = 1;//Delay till next available press
	//Constructor//
	public function new(x:Int,y:Int,id:Int) 
	{
		super(x, y);
		_id = id;
		loadGraphic(FileReg.imgEntButton, false, 16, 32);
	}
	//On pressed function
	override public function interact(_player:Player, _triggerMap:Map<Int,Triggerable>) {
		if(_canBePressed){
			FlxG.log.add("button triggered id: " + Std.string(_id));
			_triggerMap.get(_id).Trigger(_player);//Trigger associated object
			new FlxTimer(TIME_TO_BE_PRESSED_AGAIN, function(_) { _canBePressed = true; }, 1);//Cause delay
			FlxG.sound.play(FileReg.sndButton, 1, false);
			_canBePressed =false;
		}
	}
}