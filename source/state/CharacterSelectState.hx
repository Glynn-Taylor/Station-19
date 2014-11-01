package state;
import entities.Light;
import flixel.addons.ui.FlxSlider;
import flixel.animation.FlxAnimation;
import flixel.animation.FlxAnimationController;
import flixel.FlxObject;
import flixel.util.FlxColorUtil;
import flixel.util.FlxGradient;
import flixel.util.loaders.CachedGraphics;
import player.Player;
import util.CharacterCreationStore;
//import flixel.addons.ui.FlxUISlider;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
using flixel.util.FlxSpriteUtil;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.system.System;
import util.FileReg;
import util.GamepadIDs;
import util.Reg;

/**
 * @author Glynn Taylor
 * State for the character creation screen, mainly UI elements with a non-moveable, but animated character for +coolness
 */
class CharacterSelectState extends FlxState
{
	//Constants//
	private static inline var _btnOffset:Int = 32;			//Displacement(y) of buttons from one another
	private static inline var COLOR_JUMP = 2;				//Amount to shift color by for every slider movement
	//UI//
	private var _btnQuit:FlxButton;
	private var _hairChoiceMsg:FlxText;
	var sliderHair:FlxSlider;
	var sliderArmor:FlxSlider;
	var sliderSkin:FlxSlider;
	var sliderHairChoice:FlxSlider;
	private var hsv:Array<Int>;								//All HSV values
	private var hairStyles:Array<String> = [FileReg.imgPlayer, FileReg.imgPlayerMale, FileReg.imgPlayerNeutral]; //Files for hairstyle as body parts not seperate
	//PLAYER//
	private var _player:Player;								//Character and variable store
	var _char:CharacterCreationStore;
	//UTIL//
	private var darkness:FlxSprite;							//Lighting overlay
	
	//Initialisation
	override public function create():Void
	{
		FlxG.mouse.visible = true;							//Ensure mouse visibility
		bgColor = 0xFF000000;
		_player = new Player(FlxG.width / 2, 45,Reg.playerPixels==null?hairStyles[0]:"");
		_player.scale.x = _player.scale.y=4;				//Scale player to make it more visible
		_player.x -= _player.width / 2;						//Centering
		_player.moves = false;								//Prevent actual movement
		var effect:FlxSprite = new FlxSprite(0, 0);
		var bitmapdata:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x88114411);
		var scanline:BitmapData = new BitmapData(FlxG.width, 1, true, 0x88001100);
		//Draw line effects as if are old terminal
		for (i in 0...bitmapdata.height)
		{
			//Spread of bars
			if (i % 4 == 0)
			{
				bitmapdata.draw(scanline, new Matrix(1, 0, 0, 1, 0, i));	//Create a line effect
			}
		}
		
		var cX:Array<Int> = [5, 3, 2, 2, 1];
		var cY:Array<Int> = [1, 2, 2, 3, 5];
		var w:Int = bitmapdata.width;
		var h:Int = bitmapdata.height;
		// round corners
		for (i in 0...5)
		{
			bitmapdata.fillRect(new Rectangle(0, 0, cX[i], cY[i]), 0xff131c1b);
			bitmapdata.fillRect(new Rectangle(w-cX[i], 0, cX[i], cY[i]), 0xff131c1b);
			bitmapdata.fillRect(new Rectangle(0, h-cY[i], cX[i], cY[i]), 0xff131c1b);
			bitmapdata.fillRect(new Rectangle(w-cX[i], h-cY[i], cX[i], cY[i]), 0xff131c1b);
		}
		//Load the data into the sprite
		effect.loadGraphic(bitmapdata);
		add(effect);
		
		var sndSelect:FlxSound = FlxG.sound.load(FileReg.sndSelect);	//Load select sound
		
		_btnQuit = new FlxButton(0, FlxG.height/2, "Done", clickDone);	//Create button
		_btnQuit.loadGraphic(FileReg.uiBtn);
		_btnQuit.label.color = Reg.TEXT_COLOR;
		_btnQuit.x = FlxG.width / 2 - _btnQuit.frameWidth / 2;
		_btnQuit.y += 4 * _btnOffset;									//Set position
		_btnQuit.onUp.sound = sndSelect;								//set sound to select
		add(_btnQuit);													//add button to scene
		
		hsv = FlxColorUtil.getHSVColorWheel();							//Generate HSV values
        _char = new CharacterCreationStore();
		
		//Hair choice buttons and text
		var leftHairChoice = new FlxButton( FlxG.width / 2 - 75, FlxG.height / 2 + -1 * _btnOffset, "<", setHairChoiceLeft);
		leftHairChoice.scale.x = 0.3;
		leftHairChoice.x -= leftHairChoice.frameWidth / 2;
		add(leftHairChoice);
		var rightHairChoice = new FlxButton( FlxG.width / 2 + 75, FlxG.height / 2 + -1 * _btnOffset, ">", setHairChoiceRight);
		rightHairChoice.scale.x = 0.3;
		rightHairChoice.x -= rightHairChoice.frameWidth / 2;
		add(rightHairChoice);
		_hairChoiceMsg= new FlxText(0, FlxG.height / 2 + -1 * _btnOffset+10, 0,"Hair style 1", 8);
		_hairChoiceMsg.alignment = "center";
		_hairChoiceMsg.screenCenter(true, false);
		add(_hairChoiceMsg);
		//Create slider for skin color, creates function for changing color in callback
		sliderSkin = new FlxSlider(_char, "skinColor", FlxG.width/2-100, FlxG.height/2 +0 * _btnOffset,0,17,200,10,5,Reg.TEXT_COLOR,FlxColor.WHITE);
		sliderSkin.callback = function(_){_player.changeSkinColor(Math.floor(sliderSkin.value));};
		sliderSkin.setTexts("Skin color", false, null, null);
		add(sliderSkin);
	   //Create slider for armor color, creates function for changing color in callback
		sliderArmor = new FlxSlider(_char, "armorColor", FlxG.width/2-100, FlxG.height/2 +1 * _btnOffset,0,Math.floor(359/COLOR_JUMP),200,10,10,FlxColor.WHITE,FlxColor.WHITE);
		sliderArmor.callback = function(_){_player.changeArmorColor((hsv[Math.floor(sliderArmor.value * COLOR_JUMP)]));};
		sliderArmor.body.loadGraphic(FileReg.imgSliderBG, false, 200, 10);
		sliderArmor.setTexts("Armor color", false, null, null);
		add(sliderArmor);
		//Create slider for hair color, creates function for changing color in callback
		sliderHair = new FlxSlider(_char, "hairColor", FlxG.width/2-100, FlxG.height/2 +2 * _btnOffset,0,Math.floor(359/COLOR_JUMP),200,10,10,FlxColor.WHITE,FlxColor.WHITE);
		sliderHair.callback = function(_) { _player.changeHairColor((hsv[Math.floor(sliderHair.value * COLOR_JUMP)]));};
		sliderHair.body.loadGraphic(FileReg.imgSliderBG, false, 200, 10);
		sliderHair.setTexts("Hair color", false, null, null);
		add(sliderHair);
		//Create lighting overlay sprite
		darkness = new FlxSprite(0,0);
		darkness.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
		darkness.scrollFactor.x = darkness.scrollFactor.y = 0;
		darkness.blend = BlendMode.MULTIPLY;
		//Stamp a light onto the darkness sprite
		var light:Light = new Light(FlxG.width / 2, FlxG.height / 2, darkness, 25);
		light.finalise();
		//Adding the overlays last and player after to ensure player visibility
		add(light);
		add(darkness);
		add(_player);
		FlxG.camera.fade(FlxColor.BLACK, .33, true);				//Fade in
		super.create();
	}
	
	//Handles "Done" button click
	private function clickDone():Void
	{
		Reg.playerPixels = _player.pixels.clone();					//Save player bitmap data
		FlxG.camera.fade(FlxColor.BLACK, .33, false, function() {	//Fade out
			FlxG.switchState(new PlayState());
		});
	}
	//Decrement hair choice and set it, if <0 then wrap choice
	private function setHairChoiceLeft():Void {
		_char.hairChoice -= 1;
		if (_char.hairChoice < 0)
			_char.hairChoice = hairStyles.length - 1;
		setHairChoice();
	}
	//Decrement hair choice and set it, if >amount of choices then wrap choice
	private function setHairChoiceRight():Void {
		_char.hairChoice += 1;
		_char.hairChoice %= hairStyles.length;
		setHairChoice();
	}
	//Reset player's hair choice by resetting colors+player graphic and creating new animations
	private function setHairChoice():Void {
			_player.loadGraphic(hairStyles[_char.hairChoice], true, 32, 32);		//Load new graphic for hair
			_player.createAnimations();												//Recreate animations as get broken by loadGraphic
			_player.resetColorCache();												//Reset colors to default
			_hairChoiceMsg.text = "Hair style " + Std.string(_char.hairChoice+1);	//Reset hair style text
	}
	
}