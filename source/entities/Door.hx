package entities;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxPoint;
import openfl.display.BlendMode;
import util.FileReg;

/**
 * ...
 * @author Glynn Taylor
 */
class Door extends Triggerable {

	var _opening:Bool = false;
	var _closing:Bool = false;
	private static inline var OFFSET_X:Int = 4;
    public function new(x:Float, y:Float):Void {
		
		super(x, y);
		loadGraphic(FileReg.imgDoor, true, 16, 32);
		this.height = 32;
		this.width -= OFFSET_X;
		this.offset.x += OFFSET_X/2;
		animation.add("open", [0, 1, 2, 3, 4, 5, 6, 7], 16, false);
		animation.add("close", [7,6,5,4,3,2,1,0], 16, false);
		immovable = true;
    }
	override public function Trigger(cause:FlxSprite) {
		_opening = true;
		if(!_closing){
			animation.play("open", true, 0);
			_closing = true;
		}
	}
	override public function update():Void 
	{
		if (_opening) {
			if (!animation.finished) {
				animation.play("open");
			}else {
				_opening = false;
				solid = false;
			}
		}
		
		super.update();
	}
}