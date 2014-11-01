package entities;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.system.FlxSound;
import flixel.util.FlxPoint;
import util.FileReg;

/**
 * @author Glynn Taylor
 * An elevator that moves up/down between two points, only used up/down in station19, could be adapted to left/right
 */
class Elevator extends Triggerable {

	var _downwards:Bool = false;			//Moving towards second point
	var _upwards:Bool = false;				//Moving towards first point
	var _topPoint:FlxPoint;					//First point
	var _btmPoint:FlxPoint;					//Second points
	var _snd:FlxSound;
	private static inline var SPEED:Float = 0.35;
	
    public function new(x:Float, y:Float, p1:FlxPoint,p2:FlxPoint):Void {
		
		super(x, y);
		loadGraphic(FileReg.imgElevator, true, 32, 16);
		//Set offsets for door being centralised in sprite
		this.width = 30;
		this.height =10;
		this.offset.x = 1;
		this.offset.y = 2;
		//Add animations
		animation.add("moving", [0, 1], 16, false);
		animation.add("still", [0], 16, false);
		_topPoint = p1;
		_btmPoint = p2;
		immovable = true;					//Prevents moving when colliding with player
    }
	//Called by other entity such as button or trigger
	override public function Trigger(cause:FlxObject) {
		FlxG.log.add("elevator got triggered");
		//Swap directions if already moving
		if(_downwards){
			_downwards = false;
			_upwards = true;
		}else if(_upwards){
			_downwards = true;
			_upwards = false;
		}else if (x == _btmPoint.x && y >= _btmPoint.y) {
			_upwards = true;
		}else {
			_downwards = true;
		}
		_snd=FlxG.sound.play(FileReg.sndElevator, 0.5, true);	//Play sound looping
	}
	//Called every frame
	override public function update():Void 
	{
		//Move elevator
		if (_upwards) {
			y -= SPEED;
			if (x == _topPoint.x && y <= _topPoint.y){
				_upwards = false;
				_snd.stop();
			}
			animation.play("moving");
		}else if (_downwards) {
			y += SPEED;
			if (x == _btmPoint.x && y >= _btmPoint.y){
				_downwards = false;
				_snd.stop();
			}
			animation.play("moving");
		}
		super.update();
	}
}