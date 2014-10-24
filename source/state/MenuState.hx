package state ;

import entities.Light;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxDestroyUtil;
import lime.audio.openal.AL;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.system.System;
import util.FileReg;
import util.GamepadIDs;
import util.Reg;
using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Glynn Taylor
 * State for displaying the main menu
 */
class MenuState extends FlxState
{
	//Constants//
	private static inline var _btnOffset:Int = 32;
	//UI//
	private var _btnPlay:FlxButton;
	private var _btnOptions:FlxButton;
	private var _btnControls:FlxButton;
	private var _btnCredits:FlxButton;
	private var _btnQuit:FlxButton;
	private var _title1:FlxText;
	private var _warningMsg:FlxText;
	private var darkness:FlxSprite;
	 
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = true;
		bgColor = 0xFF000000;
		
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
		
		_title1 = new FlxText(0, 50,FlxG.width, "Station 19");				//Create title
		_title1.size = 32;
		_title1.color = Reg.TEXT_COLOR;
		_title1.borderStyle = FlxText.BORDER_SHADOW;				//Set shadowed border
		_title1.borderSize = 2;
		_title1.borderColor = 0x000000;
		_title1.antialiasing = false;								//Nearest neighbour rendering
		_title1.alignment = "center";
		//_title1.autoSize = true;
		//_title1.screenCenter(true,false);
		add(_title1);
		
		_warningMsg= new FlxText(0, (FlxG.height / 3) - 18, 0,"Requires controllers to play", 8);
		_warningMsg.alignment = "center";
		_warningMsg.screenCenter(true, false);
		//add(_warningMsg);
		
		var sndSelect:FlxSound = FlxG.sound.load(FileReg.sndSelect);//Load select sound
		
		_btnPlay = new FlxButton(0, 0, "Play (start)", clickPlay);			//Create button
		_btnPlay.onUp.sound = sndSelect;							//set sound to select
		_btnPlay.loadGraphic(FileReg.uiBtn);
		_btnPlay.label.color = Reg.TEXT_COLOR;
		_btnPlay.screenCenter(true, true);
		_btnPlay.y -= 1 * _btnOffset;								//Set offset
		add(_btnPlay);												//add button to scene
		
		_btnOptions = new FlxButton(0, 0, "Options", clickOptions);	//Create button
		_btnOptions.loadGraphic(FileReg.uiBtn);
		_btnOptions.label.color = Reg.TEXT_COLOR;
		_btnOptions.screenCenter();
		_btnOptions.y += 0 * _btnOffset;							//Set position
		_btnOptions.onUp.sound = sndSelect;							//set sound to select
		add(_btnOptions);											//add button to scene
		
		_btnControls = new FlxButton(0, 0, "Controls", clickControls);	//Create button
		_btnControls.loadGraphic(FileReg.uiBtn);
		_btnControls.label.color = Reg.TEXT_COLOR;
		_btnControls.screenCenter();
		_btnControls.y += 1 * _btnOffset;							//Set position
		_btnControls.onUp.sound = sndSelect;						//set sound to select
		add(_btnControls);											//add button to scene
		
		_btnCredits = new FlxButton(0, 0, "Credits", clickCredits);	//Create button
		_btnCredits.loadGraphic(FileReg.uiBtn);
		_btnCredits.label.color = Reg.TEXT_COLOR;
		_btnCredits.screenCenter();
		_btnCredits.y += 2 * _btnOffset;							//Set position
		_btnCredits.onUp.sound = sndSelect;							//set sound to select
		add(_btnCredits);											//add button to scene
		
		_btnQuit = new FlxButton(0, 0, "Quit", clickQuit);			//Create button
		_btnQuit.loadGraphic(FileReg.uiBtn);
		_btnQuit.label.color = Reg.TEXT_COLOR;
		_btnQuit.screenCenter();
		_btnQuit.y += 3 * _btnOffset;								//Set position
		_btnQuit.onUp.sound = sndSelect;							//set sound to select
		add(_btnQuit);												//add button to scene
		//var nativeBtn:FlxButton = new FlxButton(0, 0, "", clickQuit);
		//nativeBtn.loadGraphic(FileReg.nativeBtn, true, 80, 20);
		
		darkness = new FlxSprite(0,0);
		darkness.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
		darkness.scrollFactor.x = darkness.scrollFactor.y = 0;
		darkness.blend = BlendMode.MULTIPLY;
		
		var light:Light = new Light(FlxG.width / 2, FlxG.height / 2, darkness,10);
		add(light);
		add(darkness);
		
		FlxG.camera.fade(FlxColor.BLACK, .33, true);				//Fade in
		super.create();
	}
	//Handles "play" button click
	private function clickPlay():Void
	{
		FlxG.camera.fade(FlxColor.BLACK,.33, false,function() {	//Fade out
			FlxG.switchState(new CharacterSelectState());
		});
	}
	//Handles "options" button click
	private function clickOptions():Void
	{
		FlxG.camera.fade(FlxColor.BLACK,.33, false,function() {		//Fade out
			FlxG.switchState(new OptionsState());
		});
	}
	//Handles "credits" button click
	private function clickCredits():Void
	{
		FlxG.camera.fade(FlxColor.BLACK,.33, false,function() {		//Fade out
			FlxG.switchState(new InfoState("Credits","Programming: Glynn Taylor\nArt/Music: OpenGameArt (multiple)\nVicky Hedgecock: Player sprite\nPatrick Crecelius: BG music\n Framework: HaxeFlixel"));
		});
	}
	//Handles "controls" button click
	private function clickControls():Void
	{
		FlxG.camera.fade(FlxColor.BLACK,.33, false,function() {		//Fade out
			FlxG.switchState(new InfoState("Controls","Thumbstick: Look+move\nA: Jump\nX: Fire"));
		});
	}
	//Handles "quit" button click
	private function clickQuit():Void
	{
		System.exit(0);
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
		_btnPlay = FlxDestroyUtil.destroy(_btnPlay);
		_btnOptions = FlxDestroyUtil.destroy(_btnOptions);
		_btnControls = FlxDestroyUtil.destroy(_btnControls);
		_btnCredits = FlxDestroyUtil.destroy(_btnCredits);
		_btnQuit = FlxDestroyUtil.destroy(_btnQuit);
		_title1 = FlxDestroyUtil.destroy(_title1);
	}
}