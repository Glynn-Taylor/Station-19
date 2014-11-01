package entities;
import flixel.FlxObject;
import player.TextDisplay;

/**
 * @author Glynn Taylor
 * Trigger entity that adds text onto the text prompt queue when player collides
 */
class TriggerText extends Triggerable
{
	var _text:String = "";			//Text to add
	//CONSTRUCTOR//
	public function new(x:Int,y:Int,w:Float,h:Float,txt:String) 
	{
		super(x, y);
		width = w;
		height = h;
		_text = txt;
		makeGraphic(Std.int(width), Std.int(height), 0x00FFFFFF, false);
		_causeType = "text";		//Differentiate cause object
	}
	//On triggered
	override public function Trigger(cause:FlxObject) {
			//Add the text
			cast(cause, TextDisplay).displayText(_text);
			kill();
	}
}