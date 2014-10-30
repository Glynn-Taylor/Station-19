package player;

import flixel.addons.text.FlxTypeText;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import util.Reg;

/**
 * ...
 * @author ...
 */
class TextDisplay extends FlxTypeText
{
	
	var _textList:List<String> = new List<String>();
	var _displaying:Bool = false;
	
	public function new(X:Float, Y:Float, FieldWidth:Float=0, Size:Int=8, EmbeddedFont:Bool=true) 
	{
		super(X, Y, Std.int(FieldWidth), "hello", Size, EmbeddedFont);
		scrollFactor.set(0, 0);
		color = Reg.TEXT_COLOR;
		set_alpha(0.5);
		
		delay = 0.1;
		eraseDelay = 0.2;
		//showCursor = true;
		cursorBlinkSpeed = 1.0;
		prefix = "";
		autoErase = true;
		waitTime = 2.0;
		setTypingVariation(0.75, true);
		useDefaultSound = true;
		color = 0x8811EE11;
		//skipKeys = ["SPACE"];
	}
	public function displayText(txt:String) {
		_textList.add(txt);
		checkDisplaying();
	}
	private function checkDisplaying() {
		if (!_displaying) {
			if (_textList.length > 0){
					//text = _textList.first();
					resetText(_textList.first());
					useDefaultSound = true;
					start(0.03, true, true, null, null);
					_displaying = true;
					new FlxTimer(3.0, removeText, 1);
					FlxG.log.add("displaying " + _textList.first());
				}
		}
	}
	
	private function removeText(timer:FlxTimer):Void {
		_textList.remove(_textList.first());
		useDefaultSound = false;
		erase(0.01, false, null, null);
		//text = "";
		
		_displaying = false;
		checkDisplaying();
	}
}