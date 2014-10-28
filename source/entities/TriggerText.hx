package entities;
import flixel.FlxG;
import flixel.FlxObject;
import player.TextDisplay;

/**
 * ...
 * @author ...
 */
class TriggerText extends Triggerable
{
	var _triggered = false;
	var _text:String = "";
	public function new(x:Int,y:Int,w:Float,h:Float,txt:String) 
	{
		super(x, y);
		width = w;
		height = h;
		_text = txt;
		makeGraphic(Std.int(width), Std.int(height), 0x00FFFFFF, false);
		_causeType = "text";
	}
	override public function Trigger(cause:FlxObject) {
		if(!_triggered){
			cast(cause, TextDisplay).displayText(_text);
			_triggered = true;
			FlxG.log.add("triggered text");
		}
	}
}