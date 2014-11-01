package entities;
import flixel.FlxObject;
import player.Player;
import util.Reg;

/**
 * @author Glynn Taylor
 * Ladder object that disables gravity on player when player enters collider, disabling jumping handled by player
 */
class TriggerLadder extends Triggerable
{
	var _triggered = false;							//Status for if player already on ladder to reduce computation
	var _player:Player;								//Track player for checking leaving
	//CONSTRUCTOR//
	public function new(x:Int,y:Int,w:Float,h:Float) 
	{
		super(x, y);
		width = w;
		height = h;
		makeGraphic(Std.int(width), Std.int(height), 0x00FFFFFF, false);
	}
	//On player entering ladder collider
	override public function Trigger(cause:FlxObject) {
		if (!_triggered) {
			_player = cast(cause, Player);
			_player.acceleration.y = 0;					//Remove gravity from player
			_player._onLadder = true;					//Set player status
			_triggered = true;
		}
	}
	
	//Checks if player has left ladder
	override public function update():Void 
	{
		if (_triggered) {
			if (!this.overlaps(_player)) {				//Check for player left ladder
				_triggered = false;
				_player.acceleration.y = Reg.GRAVITY;	//Add gravity to player
				_player._onLadder = false;				//Set player status
			}
		}
	}
}