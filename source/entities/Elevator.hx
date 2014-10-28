package entities;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxPoint;
import openfl.display.BlendMode;
import util.FileReg;

/**
 * ...
 * @author Glynn Taylor
 */
class Elevator extends Triggerable {

	var _downwards:Bool = false;
	var _upwards:Bool = false;
	var _topPoint:FlxPoint;
	var _btmPoint:FlxPoint;
	private static inline var SPEED:Float = 0.35;
	
    public function new(x:Float, y:Float, p1:FlxPoint,p2:FlxPoint):Void {
		
		super(x, y);
		loadGraphic(FileReg.imgElevator, true, 32, 16);
		this.width = 30;
		this.height =10;
		this.offset.x = 1;
		this.offset.y = 2;
		animation.add("moving", [0, 2], 16, false);
		animation.add("still", [0], 16, false);
		_topPoint = p1;
		_btmPoint = p2;
		immovable = true;
    }
	override public function Trigger(cause:FlxObject) {
		FlxG.log.add("elevator got triggered");
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
		FlxG.log.add("this: " + Std.string(x) + "," + Std.string(y));
		FlxG.log.add("top: " + Std.string(_topPoint.x) + "," + Std.string(_topPoint.y));
		FlxG.log.add("bottom: "+Std.string(_btmPoint.x)+","+Std.string(_btmPoint.y));
		FlxG.log.add(_downwards);
	}
	override public function update():Void 
	{
		if (_upwards) {
			y -= SPEED;
			if (x == _topPoint.x && y <= _topPoint.y)
				_upwards = false;
		}else if (_downwards) {
			y += SPEED;
			if (x == _btmPoint.x && y >= _btmPoint.y)
				_downwards = false;
		}
		
		super.update();
	}
}