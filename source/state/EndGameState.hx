package state ;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepad;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import player.Player;
import util.FileReg;
import util.GamepadIDs;
import util.Reg;
using flixel.util.FlxSpriteUtil;
/**
 * ...
 * @author Glynn Taylor
 * Class that handles displaying victory text and allows for rematches/going back to menu
 */
class EndGameState extends FlxState
{
	private var _txtTitle:FlxText;		// the title text
	private var _txtMessage:FlxText;	// the final score message text
	private var _btnMainMenu:FlxButton;	// button to go to main menu
	private var _btnRematch:FlxButton;
	private var _text:String;
	var playerSprite:FlxSprite;
	var _mGibs:FlxEmitter;
	//Constructor
	public function new(text:String) 
	{
		FlxG.log.add("end game screen constructor");
		_text = text;
		super();
		
	}
	//Initialisation
	override public function create():Void 
	{
		FlxG.log.add("end game screen creation");
		FlxG.mouse.visible = true;							//Ensure mouse visibility
		bgColor = 0x000000;									//Ensure BG color
		//UI Creation//
		_txtTitle = new FlxText(0, 20, 0, _text, 22);
		_txtTitle.alignment = "center";
		_txtTitle.screenCenter(true, false);
		_txtTitle.size = 32;
		_txtTitle.x -= 20;
		_txtTitle.borderStyle = FlxText.BORDER_SHADOW;
		_txtTitle.borderSize = 2;
		_txtTitle.borderColor = 0x555555;
		_txtTitle.antialiasing = false;
		add(_txtTitle);
		
		playerSprite= new FlxSprite(32, 150);
		playerSprite.loadGraphic(FileReg.imgPlayerNeutral, true, 32, 32);
		playerSprite.animation.add("stand", [4], 6, false);	
		playerSprite.animation.play("stand");
		playerSprite.scale.set(2, 2);
		playerSprite.screenCenter(true, false);
		
		add(playerSprite);
		
		_mGibs= new FlxEmitter();						//Create emitter for gibs
		_mGibs.setXSpeed( -150, 150);					//Gib settings
		_mGibs.setYSpeed( -200, 0);
		_mGibs.acceleration.y = 400;						//Add gravity to gibs
		_mGibs.setRotation( -720, 720);
		_mGibs.makeParticles(FileReg.imgPGibs, 25, 16, true, .5);	//Setup gib tilesheet
		add(_mGibs);
		
		if (_text != "You escaped!") {
			new FlxTimer(1.5, function(_) { playerSprite.kill();FlxG.sound.play(FileReg.sndPlayerDeath); _mGibs.at(playerSprite);
			_mGibs.start(true, 2.80); } );
			
			FlxG.sound.play(FileReg.sndPlayerDeathAmbient);
		}
		_btnMainMenu = new FlxButton(0, FlxG.height - 32, "Main Menu", goMainMenu);
		_btnMainMenu.screenCenter(true, false);
		add(_btnMainMenu);
		_btnRematch = new FlxButton(0, FlxG.height - 64, "Restart", goPlay);
		_btnRematch.screenCenter(true, false);
		add(_btnRematch);
		
		super.create();
		FlxG.camera.fade(FlxColor.BLACK, .33, true);		//Fadein
		FlxG.gamepads.reset();
	}
	override public function update():Void 
	{
		
			super.update();
		
	}
	
	//When the user hits the main menu button, it should fade out and then take them back to the MenuState
	private function goMainMenu():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, .66, false, function() {
			FlxG.switchState(new MenuState());
		});
	}
	//When the user hits the rematch button, it should fade out and then take them back to the PlayState
	private function goPlay():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, .66, false, function() {
			FlxG.switchState(new CharacterSelectState());
		});
	}
	//Cleanup
	override public function destroy():Void 
	{
		super.destroy();
		_txtTitle = FlxDestroyUtil.destroy(_txtTitle);
		_txtMessage = FlxDestroyUtil.destroy(_txtMessage);
		_btnMainMenu = FlxDestroyUtil.destroy(_btnMainMenu);
		_btnRematch= FlxDestroyUtil.destroy(_btnRematch);
		_text = null;
	}
	
}