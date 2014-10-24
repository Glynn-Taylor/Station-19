package state;
import entities.Light;
import flixel.addons.ui.FlxSlider;
import flixel.FlxObject;
import flixel.util.FlxColorUtil;
import flixel.util.FlxGradient;
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
import flixel.util.FlxSpriteUtil;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.system.System;
import util.FileReg;
import util.GamepadIDs;
import util.Reg;

/**
 * ...
 * @author Glynn Taylor
 */
class CharacterSelectState extends FlxState
{

	//Constants//
	private static inline var _btnOffset:Int = 32;
	//UI//
	private var _btnQuit:FlxButton;
	private var _warningMsg:FlxText;
	private var darkness:FlxSprite;
	//PLAYER//
	private var _player:Player;
	//SLIDERS//
	private static inline var COLOR_JUMP = 2;
	var sliderHair:FlxSlider;
	var sliderArmor:FlxSlider;
	var sliderSkin:FlxSlider;
	private var hsv:Array<Int>;
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = true;
		bgColor = 0xFF000000;
		_player = new Player(FlxG.width / 2, 45);
		_player.scale.x = _player.scale.y=4;
		_player.x -= _player.width / 2;
		_player.moves = false;
		var effect:FlxSprite = new FlxSprite(0, 0);
		var bitmapdata:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x88114411);
		var scanline:BitmapData = new BitmapData(FlxG.width, 1, true, 0x88001100);
		
		for (i in 0...bitmapdata.height)
		{
			if (i % 4 == 0)
			{
				bitmapdata.draw(scanline, new Matrix(1, 0, 0, 1, 0, i));
			}
		}
		
		// round corners
		
		var cX:Array<Int> = [5, 3, 2, 2, 1];
		var cY:Array<Int> = [1, 2, 2, 3, 5];
		var w:Int = bitmapdata.width;
		var h:Int = bitmapdata.height;
		
		for (i in 0...5)
		{
			bitmapdata.fillRect(new Rectangle(0, 0, cX[i], cY[i]), 0xff131c1b);
			bitmapdata.fillRect(new Rectangle(w-cX[i], 0, cX[i], cY[i]), 0xff131c1b);
			bitmapdata.fillRect(new Rectangle(0, h-cY[i], cX[i], cY[i]), 0xff131c1b);
			bitmapdata.fillRect(new Rectangle(w-cX[i], h-cY[i], cX[i], cY[i]), 0xff131c1b);
		}
		
		effect.loadGraphic(bitmapdata);
		add(effect);
		
		
		_warningMsg= new FlxText(0, (FlxG.height / 3) - 18, 0,"Requires controllers to play", 8);
		_warningMsg.alignment = "center";
		//_warningMsg.screenCenter(true, false);
		//add(_warningMsg);
		
		var sndSelect:FlxSound = FlxG.sound.load(FileReg.sndSelect);//Load select sound
		
		
		
		_btnQuit = new FlxButton(0, FlxG.height/2, "Done", clickDone);			//Create button
		_btnQuit.loadGraphic(FileReg.uiBtn);
		_btnQuit.label.color = Reg.TEXT_COLOR;
		//_btnQuit.screenCenter();
		_btnQuit.x = FlxG.width / 2 - _btnQuit.width / 2;
		_btnQuit.y += 4 * _btnOffset;								//Set position
		_btnQuit.onUp.sound = sndSelect;							//set sound to select
		add(_btnQuit);	//add button to scene
		hsv = FlxColorUtil.getHSVColorWheel();

        var _char:CharacterCreationStore = new CharacterCreationStore();
       // add(_char);
		
		sliderSkin = new FlxSlider(_char, "skinColor", FlxG.width/2-100, FlxG.height/2 +0 * _btnOffset,0,17,200,10,10,FlxColor.WHITE,FlxColor.WHITE);
		sliderSkin.callback = setSkinColor;
		sliderSkin.setTexts("Skin color", false, null, null);
		add(sliderSkin);
	   
		sliderArmor = new FlxSlider(_char, "armorColor", FlxG.width/2-100, FlxG.height/2 +1 * _btnOffset,0,Math.floor(359/COLOR_JUMP),200,10,10,FlxColor.WHITE,FlxColor.WHITE);
		sliderArmor.callback = setArmorColor;
		sliderArmor.body.loadGraphic(FileReg.imgSliderBG, false, 200, 10);
		sliderArmor.setTexts("Armor color", false, null, null);
		add(sliderArmor);
		
		sliderHair = new FlxSlider(_char, "hairColor", FlxG.width/2-100, FlxG.height/2 +2 * _btnOffset,0,Math.floor(359/COLOR_JUMP),200,10,10,FlxColor.WHITE,FlxColor.WHITE);
		sliderHair.callback = setHairColor;
		sliderHair.body.loadGraphic(FileReg.imgSliderBG, false, 200, 10);
		sliderHair.setTexts("Hair color", false, null, null);
		//slider.body=FlxGradient.createGradientFlxSprite(200, 10, [0x00000, 0xFFFFFF], 2 );
		//slider.handle.loadGraphic(FileReg.imgSlider, false, 32, 32);
		//slider.setVariable = false;
		add(sliderHair);
		
		  // var slider2 = new FlxSlider(_char, "x", 0, 240, 0, FlxG.width, 640, 50, 3, FlxColor.WHITE);
		  // add(slider2);
              //  slider.nameLabel.visible = false;
                //slider.valueLabel.visible = false;
                //slider.minLabel.visible = false;
                //slider.maxLabel.visible = false;
                //add(slider);
		//var nativeBtn:FlxButton = new FlxButton(0, 0, "", clickQuit);
		//nativeBtn.loadGraphic(FileReg.nativeBtn, true, 80, 20);
		
		darkness = new FlxSprite(0,0);
		darkness.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
		darkness.scrollFactor.x = darkness.scrollFactor.y = 0;
		darkness.blend = BlendMode.MULTIPLY;
		
		var light:Light = new Light(FlxG.width / 2, FlxG.height / 2, darkness,25);
		add(light);
		add(darkness);
		add(_player);
		FlxG.camera.fade(FlxColor.BLACK, .33, true);				//Fade in
		super.create();
	}
	
	//Handles "Done" button click
	private function clickDone():Void
	{
		Reg.playerPixels = _player.pixels.clone();
		FlxG.camera.fade(FlxColor.BLACK, .33, false, function() {		//Fade out
			FlxG.switchState(new PlayState());
		});
	}

	//Called every frame
	override public function update():Void
	{
		
		super.update();
	}
	override public function draw():Void {
		FlxSpriteUtil.fill(darkness, 0xff000000);
		super.draw();
	}
	//Cleanup
	override public function destroy():Void
	{
		super.destroy();
		_btnQuit = FlxDestroyUtil.destroy(_btnQuit);
	}
	private function setHairColor(c:Float):Void {
		_player.changeHairColor((hsv[Math.floor(sliderHair.value * COLOR_JUMP)]));
	}
	private function setArmorColor(c:Float):Void {
		_player.changeArmorColor((hsv[Math.floor(sliderArmor.value * COLOR_JUMP)]));
	}
	private function setSkinColor(c:Float):Void {
		_player.changeSkinColor(Math.floor(sliderSkin.value));
	}
	
}