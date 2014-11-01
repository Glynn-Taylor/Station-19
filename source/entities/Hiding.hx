package entities;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import player.Player;
import util.FileReg;

/**
 * @author ApexRUI
 * A useable hiding spot that hides the player from monster if they are not tracking them
 */
class Hiding extends Useable
{
	private var _amIn:Bool = false;				//Whether or not player is inside
	private var _canBePressed:Bool = true;		//Bool to prevent continuous in/out 
	
	//CONSTRUCTOR//
	public function new(x:Int,y:Int) 
	{
		super(x, y);
		loadGraphic(FileReg.imgCupboard, false, 16, 32);
		animation.add("open", [2,1,0], 4, false);
		animation.add("close", [0,1,2], 4, false);
	}
	
	override public function interact(_player:Player, _triggerMap:Map<Int,Triggerable>) {
		if(_canBePressed){
			_player._isHidden = !_player._isHidden;			//Update player with hidden status
			_amIn = !_amIn;
			FlxG.sound.play(FileReg.sndButton, 1, false);
			if(_amIn){
				animation.play("close");
				FlxTween.tween(_player,{alpha: 0}, 1);		//Tween player alpha after playing close anim
				_player.forceLightOff();					//Ensure player flashlight turns off as hiding
			}else {
				FlxTween.tween(_player,{alpha: 1}, 1);
				animation.play("open");
			}
			new FlxTimer(1, function(_) { _canBePressed = true; }, 1);//Allow more presses after a second
			_canBePressed = false;
		}
		
	}
}