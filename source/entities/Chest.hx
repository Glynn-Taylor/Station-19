package entities;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import player.Player;
import util.FileReg;
/**
 * @author ApexRUI
 * A useable chest that dispenses ammo and displays a fading +(ammo) prompt on button press
 */
class Chest extends Useable
{
	private var _amount:Int;					//Amount of ammo
	private var _canBeOpened:Bool = true;		//Has not been opened before?
	
	public function new(x:Int,y:Int,amount:Int) 
	{
		super(x, y);
		_amount = amount;
		loadGraphic(FileReg.imgChest, false, 16, 16);
		animation.add("open", [0, 1, 2], 4, false);	//Add opening animation
	}
	
	override public function interact(_player:Player, _triggerMap:Map<Int,Triggerable>) {
		if(_canBeOpened){
			FlxG.sound.play(FileReg.sndChest, 1, false);
			_player.addAmmo(_amount);
			_canBeOpened = false;
			animation.play("open");
			var text : FlxText = new FlxText(x, y, 20, "+" + Std.string(_amount)); //Create the text
			FlxG.state.add(text);
			//Tween fading of text to invisible then destroy when it is (on complete)
			FlxTween.tween(text, { alpha:0 }, 1, { ease: FlxEase.quadInOut, complete: function(_) { text.destroy(); } } );
		}
	}
}