package entities;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import player.Player;
import util.FileReg;

/**
 * ...
 * @author ApexRUI
 */
class Hiding extends Useable
{
	private var _amIn:Bool = false;
	private var _canBePressed:Bool = true;
	
	public function new(x:Int,y:Int) 
	{
		super(x, y);
		loadGraphic(FileReg.imgCupboard, false, 16, 32);
		animation.add("open", [2,1,0], 4, false);
		animation.add("close", [0,1,2], 4, false);
	}
	
	override public function interact(_player:Player, _triggerMap:Map<Int,Triggerable>) {
		if(_canBePressed){
			_player._isHidden = !_player._isHidden;
			//_player.alpha = _player._isHidden?0.2:1;
			_amIn = !_amIn;
			FlxG.sound.play(FileReg.sndButton, 1, false);
			if(_amIn){
				animation.play("close");
				FlxTween.tween(_player,{alpha: 0}, 1);
				_player.forceLightOff();
			}else {
				FlxTween.tween(_player,{alpha: 1}, 1);
				animation.play("open");
			}
			new FlxTimer(1, canBePressedAgain, 1);
			_canBePressed = false;
		}
		
	}
	override public function update():Void 
	{
		if (!animation.finished) {
			if(_amIn){
				animation.play("close");
			}else {
				animation.play("open");
			}
		}
		super.update();
	}
	private function canBePressedAgain(Timer:FlxTimer):Void
	{
		_canBePressed = true;
	}
}