package player;

import flixel.addons.text.FlxTypeText;
import flixel.util.FlxTimer;
import util.Reg;

/**
 * @author Glynn Taylor
 * State for queuing up text prompts to display to the user, also has a nice type text effect, thanks Flixel!
 */
class TextDisplay extends FlxTypeText
{
	var _textList:List<String> = new List<String>();	//Queue of text to display
	var _displaying:Bool = false;						//Prevents text being overwritten whilst still displaying
	
	public function new(X:Float, Y:Float, FieldWidth:Float=0, Size:Int=8, EmbeddedFont:Bool=true) 
	{
		super(X, Y, Std.int(FieldWidth), "", Size, EmbeddedFont);
		scrollFactor.set(0, 0);							//Prevents scrolling and keeps in UI
		set_alpha(0.5);									//Prevent text standing out too much
		
		delay = 0.1;									//Delays between characters
		eraseDelay = 0.2;
		prefix = "";									//Prevent prefix
		autoErase = true;
		waitTime = 2.0;
		setTypingVariation(0.75, true);					//Adds typing variation to make typing feel more natural
		useDefaultSound = true;
		color = 0x8811EE11;
	}
	//Adds text to the queue and checks if can display it
	public function displayText(txt:String) {
		_textList.add(txt);
		checkDisplaying();
	}
	private function checkDisplaying() {
		if (!_displaying) {								//No need to check if text already displaying
			if (_textList.length > 0){
					resetText(_textList.first());		//Set text to Queue head
					useDefaultSound = true;
					start(0.03, true, true, null, null);//Start writing text
					_displaying = true;
					new FlxTimer(3.0, removeText, 1);	//Remove text in 3 seconds (removecheck checksdisplaying again to check for things left to display)
				}
		}
	}
	//Removes current text and checks for more to display.
	private function removeText(timer:FlxTimer):Void {
		_textList.remove(_textList.first());			//Remove text
		useDefaultSound = false;
		erase(0.01, false, null, null);					//Erase to ""
		_displaying = false;
		checkDisplaying();								//Add another text in if text left in queue
	}
}