package player;

import flixel.text.FlxText;
import flixel.util.FlxTimer;
import util.Reg;

/**
 * ...
 * @author ...
 */
class TextDisplay extends FlxText
{
	
	var _textList:List<String> = new List<String>();
	var _displaying:Bool = false;
	
	public function new(X:Float, Y:Float, FieldWidth:Float=0, Size:Int=8, EmbeddedFont:Bool=true) 
	{
		super(X, Y, FieldWidth, "", Size, EmbeddedFont);
		scrollFactor.set(0, 0);
		color = Reg.TEXT_COLOR;
		set_alpha(0.5);
	}
	public function displayText(txt:String) {
		_textList.add(txt);
		checkDisplaying();
	}
	private function checkDisplaying() {
		if (!_displaying) {
			if (_textList.length > 0){
					text = _textList.first();
					_displaying = true;
					new FlxTimer(3.0, removeText, 1);
				}
		}
	}
	
	private function removeText(timer:FlxTimer):Void {
		_textList.remove(_textList.first());
		text = "";
		checkDisplaying();
		_displaying = false;
	}
}