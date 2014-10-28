package entities;
import flixel.FlxG;
import flixel.FlxObject;
import player.Player;
import util.Reg;

/**
 * ...
 * @author ...
 */
class TriggerLadder extends Triggerable
{
	var _triggered = false;
	var _player:Player;
	
	public function new(x:Int,y:Int,w:Float,h:Float) 
	{
		super(x, y);
		width = w;
		height = h;
		makeGraphic(Std.int(width), Std.int(height), 0x00FFFFFF, false);
	}
	override public function Trigger(cause:FlxObject) {
		if (!_triggered) {
			_player = cast(cause, Player);
			_player.acceleration.y = 0;
			_player._onLadder = true;
			_triggered = true;
			FlxG.log.add("on ladder");
		}
	}
	
	override public function update():Void 
	{
		if (_triggered) {
			if (!this.overlaps(_player)) {
				_triggered = false;
				_player.acceleration.y = Reg.GRAVITY;
				_player._onLadder = false;
				FlxG.log.add("off ladder");
			}
		}
	}
}