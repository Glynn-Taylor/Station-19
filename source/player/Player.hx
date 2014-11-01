package player ;

import entities.Light;
import flixel.addons.ui.FlxUIGroup;
import flixel.addons.weapon.FlxWeapon;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxColorUtil;
import flixel.util.FlxMath;
import flixel.util.FlxTimer;
import state.EndGameState;
import util.FileReg;
import util.GamepadIDs;
import util.Reg;

/**
 * @author Glynn Taylor
 * Player sprite and logic
 */
class Player extends FlxSprite
{
	//Constant vars
	private static inline var SPEED:Float = 10;
	private static inline var DASH_SPEED:Float = 100;
	private static inline var FLASHLIGHT_X:Int = 8;
	private static inline var FLASHLIGHT_Y:Int = -5;
	private static inline var FLASHLIGHT_RATE:Float = 0.1;
	private static inline var MAX_AMMO_IN_CLIP:Int = 16;
	private static inline var RELOAD_TIME:Int = 1;
	private static inline var UI_X:Int = 7;
	private static inline var UI_Y:Int = 20;
	//Reference vars
	//Data vars
	private var _lastAngle:Float = 0;
	private var _hasFired:Bool = false;
	private var _hasDashed:Bool = false;
	private var _numArrows:Int = 3;
	private var _flashLightEquipped:Bool = false;
	public var _isHidden:Bool = false;
	public var _onLadder:Bool = false;
	private var _reloading:Bool = false;
	private var _canToggle:Bool=true;
	private var _flashLightEnergy:Float = 100;
	private var _ammoInClip:Int = 16;
	private var _ammoOutOfClip:Int = 32;
	private var _lightLevel:Float = 100;
	private var _lights:FlxTypedGroup<Light>;
	private var _inLight:Bool = true;
	private var _flashLightClear = false;
	//Sound vars
	private var _sndStep:FlxSound;
	private var _sndFire:FlxSound;
	//UI vars
	public var _flashLight:FlashLight;
	private var _ammoText:FlxText;
	public var _rifle:FlxWeapon;
	private var _flashlightBar:FlxBar;
	private var _healthBar:FlxBar;
	//Original Color values//
	private var _hair:Array<Int> = [0xFFEFD074, 0xFFD58308, 0xFF824100];
	private var _hairGreyscale:Array<Int> = [0xFFCECECE, 0xFF8D8D8D, 0xFF4D4D4D];
	private var _armor:Array<Int> = [0xFFFFF200, 0xFFFFC90E];
	private var _armorGreyscale:Array<Int> = [0xFFDADADA, 0xFFC3C3C3];
	private var _skin:Array<Int> = [0xFFF6D5A4, 0xFFDE9462];
	private var _skinGreyscale:Array<Int> = [0xFFFFFFFF, 0xFFD4D4D4];
	private var _skinSwatch:Array<Int> = [0xFFF6D5A4, 0xFFF6D5A4, 0xFFCFAC84, 0xFFCFA97A, 0xFFC29369, 0xFFBA8960, 0xFFB57D58, 0xFFBD815C, 0xFFAA7651, 0xFFA87445, 0xFF8E5B3C, 0xFF845239, 0xFF7E4E37, 0xFF6B4532, 0xFF67452C, 0xFF502F1E, 0xFF573C27, 0xFF31221B];
	//Darkness//
	private var _darknessMonster:FlxSprite;
	private var _darknessTeleporting:Bool = false;
	private var _darknessSound:FlxSound;
	
	//Constructor
	public function new(X:Float=0, Y:Float=0,graphic:String) 
	{											//Set player id (controller number)
		super(X, Y);
		if(Reg.playerPixels==null||graphic!="")
			loadGraphic(graphic, true, 32, 32);	//Load sprite
		else
			loadGraphic(Reg.playerPixels.clone(), true, 32, 32);
		
		createAnimations();
		maxVelocity.set(80, 400);
		acceleration.y = Reg.GRAVITY;									//Setup gravity
		drag.x = maxVelocity.x * 10;
		setGameScale();
		
		//Bounding box
		width = 14;
		height = 24;
		offset.x = 8;
		offset.y = 5;
		
		//centerOffsets();
		//Sounds
		_sndStep = FlxG.sound.load(FileReg.sndStep, 0.5, false);
		_sndFire = FlxG.sound.load(FileReg.sndFire, 1, false);
		
		//Setup UI
		_ammoText = new FlxText(UI_X+16, 0,0, Std.string(_ammoInClip)+"/"+Std.string(_ammoOutOfClip), 8);
		_ammoText.color = Reg.TEXT_COLOR;
		_ammoText.alpha = 0.5;
		_ammoText.antialiasing = false;
		_flashlightBar = new FlxBar(UI_X+16, UI_Y, FlxBar.FILL_LEFT_TO_RIGHT);
		_flashlightBar.createImageBar(null, FileReg.uiFlashlightBar, 0x88000000);
		_flashlightBar.scrollFactor.x = _flashlightBar.scrollFactor.y = 0;
		_healthBar = new FlxBar(UI_X + 16, UI_Y + 18 , FlxBar.FILL_LEFT_TO_RIGHT);
		_healthBar.createImageBar(null, FileReg.uiFlashlightBar, 0x88000000);
		_healthBar.scrollFactor.x = _healthBar.scrollFactor.y = 0;
		//_flashLight.scale.x = _flashLight.scale.y = 0.5;
		
		makeWeapon();
		health = 100;
		
		_darknessMonster = new FlxSprite( -50, 10);
		_darknessMonster.loadGraphic(FileReg.imgDarkness, true, 24, 32, false);
		_darknessMonster.animation.add("move", [0,1,2], 6, true);
		_darknessMonster.animation.play("move");
		_darknessMonster.alpha = 0;
		_darknessSound = FlxG.sound.play(FileReg.sndMDarkness,1,true);
		_darknessSound.volume = 0;
		FlxG.state.add(_darknessMonster);
	}
	
	//GAME LOGIC//
	
	//Runs every frame
	override public function update():Void 
	{
		//Check for flashlight clear
		if (_flashLightClear) {
			_flashLight.clear();
			_flashLightClear = false;
		}
		acceleration.x = 0;					//Allow for sharp movement
		//Move if not hiding
		if (!_isHidden) {
			//Keyboard
			keyboardMovement();				//Movement
			keyboardButtons();				//Other buttons
			//Controller
			updateAxis(GamepadIDs.LEFT_ANALOGUE_X, GamepadIDs.LEFT_ANALOGUE_Y);
			updateButtons();
		}
		checkAnimation(); 					//Sets facing direction and flashlight facing
		
		if (_flashLightEquipped&&_flashLight.visible) {
			_flashLightEnergy -= FLASHLIGHT_RATE;//Decrease flashlight energy
			if (_flashLightEnergy < 1){		//Turn of flashlight when power runs out
				forceLightOff();
			}
			//Sync flashlight position
			_flashLight.setPosition(this.x + FLASHLIGHT_X - (_flashLight.facing == FlxObject.LEFT?_flashLight.width:0), this.y + FLASHLIGHT_Y);
	
		}else {
			//Increase flashlight energy if off
			if (_flashLightEnergy < 100)
				_flashLightEnergy += FLASHLIGHT_RATE;
		}
		
		//Update UI elements
		_flashlightBar.percent = _flashLightEnergy;
		_healthBar.percent = health;
		
		if (!_inLight) {
			_lightLevel -= 0.07;	//Decrement light level if not in any lights
		}
		if (_lightLevel < 80)
			updateDarkness();		//Acitvate darkness when light level low
		super.update();
	}
	//Updates darkness monster if light level low enough
	function updateDarkness() 
	{
		if (_flashLight.visible) {
			if(!_darknessTeleporting)
				if (_darknessMonster.x > x && facing == FlxObject.RIGHT) {
					FlxTween.tween(_darknessMonster,{alpha: 0}, 1);
					new FlxTimer(1, function(_) { _darknessTeleporting=false; }, 1);
				}else if (_darknessMonster.x < x && facing == FlxObject.LEFT) {
					FlxTween.tween(_darknessMonster,{alpha: 0}, 1);
					new FlxTimer(1, function(_) { _darknessTeleporting=false; }, 1);
				}else {
					_darknessMonster.y = y;
					if (FlxMath.distanceBetween(_darknessMonster, this) > _lightLevel)
						_darknessMonster.x = x + (facing == FlxObject.LEFT?_lightLevel: -_lightLevel);
					_darknessMonster.x +=	(facing == FlxObject.LEFT?0.1: -0.1);
					_darknessMonster.alpha = 1 - _lightLevel / 100;
					_darknessSound.volume = 1 - _lightLevel / 100;
				}
		}else {
			if (!_darknessTeleporting) {
				_darknessMonster.y = y;
				if (FlxMath.distanceBetween(_darknessMonster, this) > _lightLevel)
					_darknessMonster.x = x + (facing == FlxObject.LEFT?_lightLevel: -_lightLevel);
				_darknessMonster.x +=	(facing == FlxObject.LEFT?0.1: -0.1);
				_darknessMonster.alpha = 1 - _lightLevel / 100;
				_darknessSound.volume = 1 - _lightLevel / 100;
			}
		}
		
		if (_darknessMonster.alpha > 0.8)
		if (overlaps(_darknessMonster)) {
			kill();
		}
	}
	//Creates weapon and creates bullets
	public function makeWeapon() 
	{
		_rifle = new FlxWeapon("rifle", this);
		_rifle.makePixelBullet(100, 1, 1, 0xff444444, 13, 12);	//Tell the weapon to create bullets
		_rifle.setBulletSpeed(256);								//Bullets will move at 120px/sec
		_rifle.setBulletGravity(0, 0);
		_rifle.setFireRate(200);								//Fire every 200ms
		_rifle.setBulletBounds(FlxG.worldBounds);				//Allow bullets anywhere inside world
		FlxG.state.add(_rifle.group);
	}
	//Set players scale to be smaller for game world
	public function setGameScale():Void {
		scale.set(0.5, 0.8);									//Make slightly smaller for game world
	}
	//Assigns player animations
	public function createAnimations() {
		setFacingFlip(FlxObject.LEFT, false, false);			//Assign flipping of animation based on "facing" variable
		setFacingFlip(FlxObject.RIGHT, true, false);			
		animation.add("d", [4, 4, 4, 4], 6, false);				//Assign frames to animation names
		animation.add("lr", [8, 9, 10, 11, 12, 13, 14, 15], 12, false);
		animation.add("u", [4, 4, 4, 4], 6, false);
	}
	//Start light tracking, light is checked every 0.5 seconds (if in light, darkness monster will run away)
	public function trackLight(lights:FlxTypedGroup<Light>) {
		_lights = lights;
		new FlxTimer(0.5, checkLight, 0);	//Loop indef
	}
	//Checks if near any of the lights
	private function checkLight(timer:FlxTimer) {
		_inLight = false;
		for (light in _lights) {
			//20 px roughly size of actual width/height
			if (FlxMath.distanceBetween(this, light) < light.scale.x * 20) {	//If near any of the lights then set status
				_inLight = true;
				break;
			}
		}
		if (_inLight){
			_lightLevel = 100;										//Reset light level
			FlxTween.tween(_darknessMonster,{alpha: 0}, 0.5);		//Fadeout monster
			_darknessSound.volume = 0;								//Cut monster sound
			_darknessMonster.setPosition( -10, 50);					//Hide monster offscreen
		}
	}
	//Starts the reloading sequence on key press
	function reload() {
		if (_ammoOutOfClip > 0) {
			if (!_reloading) {
				new FlxTimer(RELOAD_TIME, reloadWeapon, 1);			//Reload ammo after reloading time elapsed
				_reloading = true;
				FlxG.sound.play(FileReg.sndWEmpty);
				FlxG.sound.play(FileReg.sndWReload);
			}
		}else {
			FlxG.sound.play(FileReg.sndWEmpty);						//Out of ammo
		}
	}
	//Reloads the weapon by adding the relevant amount to the inclip ammo
	function reloadWeapon(timer:FlxTimer) 
	{
		_ammoInClip = _ammoOutOfClip>MAX_AMMO_IN_CLIP?MAX_AMMO_IN_CLIP:_ammoOutOfClip;	//Add most amount
		_ammoOutOfClip -= _ammoInClip;								//Substract difference
		_reloading = false;
		updateAmmoText();											//Update ammo ui text
	}
	
	//Adds ammo to the out of clip ammo
	public function addAmmo(amount:Int):Void {
		_ammoOutOfClip += amount;
		updateAmmoText();						//Update ammo ui text
	}
	//Allows the player to toggle objects again
	function allowToggle(timer:FlxTimer) {
		_canToggle = true;
	}
	//Updates which direction player is facing so animations can flip
	function checkAnimation() 
	{
			//Animation//
			if (acceleration.x > 0) {
				facing = FlxObject.RIGHT;						//Facing determines flipping
				animation.play("lr");
				if (_flashLightEquipped)
					_flashLight.facing= FlxObject.RIGHT;
			}else if (acceleration.x < 0) {
				animation.play("lr");
				facing = FlxObject.LEFT;
				if (_flashLightEquipped)
					_flashLight.facing= FlxObject.LEFT;
			}else {
				animation.play("u");							//Idling anim
			}
	}
	
	//USER INPUT FUNCTIONS//
	
	//Handles keyboard movement keys
	function keyboardMovement() 
	{
		var _up:Bool = FlxG.keys.anyPressed(["UP", "W"]);
		var _down:Bool = FlxG.keys.anyPressed(["DOWN", "S"]);
		var _left:Bool = FlxG.keys.anyPressed(["LEFT", "A"]);
		var _right:Bool = FlxG.keys.anyPressed(["RIGHT", "D"]);
		
		if (_left || _right) {
			acceleration.x = maxVelocity.x * 5*(_left?-1:1);		//Create x movement
		}
		if(_up){
			if (!_onLadder) {
				if(isTouching(FlxObject.FLOOR)){
					velocity.y = -maxVelocity.y / 3;				//Jump
				}
			}else {
				velocity.y = maxVelocity.x*-1;						//Move up
			}
		}else if (_down) {
			if (_onLadder)
				velocity.y = maxVelocity.x;							//Move down
		}else {
			if (_onLadder)
				velocity.y = 0;										//Prevent slippage
		}
	}
	//Handles keyboard buttons
	function keyboardButtons() 
	{
		
		if(FlxG.keys.pressed.ESCAPE ){
			FlxG.camera.fade(FlxColor.BLACK, .66, false, function() {	//Fade out
				FlxG.switchState(new EndGameState("Restart?"));	//Switch state
			});
		}
		if (FlxG.keys.pressed.SPACE&&FlxG.game.ticks >=_rifle.nextFire)
		{
			if(_ammoInClip>0){
				FlxG.log.add("Fired bullet");
				_rifle.fireFromAngle(facing == FlxObject.LEFT?FlxWeapon.BULLET_LEFT:FlxWeapon.BULLET_RIGHT);
				FlxG.sound.play(FileReg.sndWRifle);
				_ammoInClip--;
				updateAmmoText();
			}else {
				reload();
			}
		}
		if (FlxG.keys.pressed.F )
		{
			if (_canToggle) {
				_canToggle = false;
				FlxG.sound.play(FileReg.sndToggle, 1, false);
				_flashLight.visible = !_flashLight.visible;
				
				new FlxTimer(0.3, allowToggle, 1);
				_flashLightClear = true;
			}
		}
		if (FlxG.keys.pressed.R )
		{
			reload();
		}
		
	}
	//Handles movement and animation after checking controller stick
	private function updateAxis(xID:Int, yID:Int):Void
	{
		//Currently no controller support
	}
	//Checks controller buttons
	private function updateButtons():Void {
		//Currently no controller support
	}
	//CHAR CREATION FUNCTIONS//
	
	//Changes player hair color
	public function changeHairColor(col:Int):Void {
		for ( i  in 0 ... _hair.length) {
			var newCol:Int =FlxColorUtil.makeFromARGB(1,Math.floor(FlxColorUtil.getRed(col) * FlxColorUtil.getRed(_hairGreyscale[i]) / 255),Math.floor(FlxColorUtil.getGreen(col) * FlxColorUtil.getGreen(_hairGreyscale[i]) / 255),Math.floor(FlxColorUtil.getBlue(col) * FlxColorUtil.getBlue(_hairGreyscale[i]) / 255));
			if (newCol != FlxColor.BLACK){
				replaceColor(_hair[i], newCol, false);
				_hair[i] = newCol;
			}

		}
	}
	public function changeArmorColor(col:Int):Void {
		for ( i  in 0 ... _armor.length) {
			var newCol:Int =FlxColorUtil.makeFromARGB(1,Math.floor(FlxColorUtil.getRed(col) * FlxColorUtil.getRed(_armorGreyscale[i]) / 255),Math.floor(FlxColorUtil.getGreen(col) * FlxColorUtil.getGreen(_armorGreyscale[i]) / 255),Math.floor(FlxColorUtil.getBlue(col) * FlxColorUtil.getBlue(_armorGreyscale[i]) / 255));
			if (newCol != FlxColor.BLACK){
				replaceColor(_armor[i], newCol, false);
				_armor[i] = newCol;
			}

		}
	}
	public function changeSkinColor(index:Int):Void {
		var col:Int = _skinSwatch[index];
		for ( i  in 0 ... _skin.length) {
			var newCol:Int =FlxColorUtil.makeFromARGB(1,Math.floor(FlxColorUtil.getRed(col) * FlxColorUtil.getRed(_skinGreyscale[i]) / 255),Math.floor(FlxColorUtil.getGreen(col) * FlxColorUtil.getGreen(_skinGreyscale[i]) / 255),Math.floor(FlxColorUtil.getBlue(col) * FlxColorUtil.getBlue(_skinGreyscale[i]) / 255));
			if (newCol != FlxColor.BLACK){
				replaceColor(_skin[i], newCol, false);
				_skin[i] = newCol;
			}

		}
	}
	//Reset colors to default values
	public function resetColorCache() {
		_hair = [0xFFEFD074, 0xFFD58308, 0xFF824100];
		_armor= [0xFFFFF200, 0xFFFFC90E];
		_skin= [0xFFF6D5A4, 0xFFDE9462];
	}
	
	//UI FUNCTIONS//
	
	//Creates a flashlight fo the player
	public function createFlashLight(darkness:FlxSprite) {
		_flashLight = new FlashLight(this.x, this.y, darkness, 1);
		_flashLight.loadGraphic(FileReg.imgFlashlight, false, 128, 32);
		_flashLight.setFacingFlip(FlxObject.LEFT, true, false);		//Assign flipping of animation based on "facing" variable
		_flashLight.setFacingFlip(FlxObject.RIGHT, false, false);	
		FlxG.state.add(_flashLight);
		_flashLightEquipped = true;
		_flashLight.facing = FlxObject.LEFT;						//Player defaults facing left
		_flashLight.set_visible(false );							//Initially flashlight off
	}
	//Adds elements to the UI group for the UI camera, also creates elements that dont need to be global
	public function addUI(grp:FlxUIGroup):Void {
		grp.add(_flashlightBar);
		grp.add(_healthBar);
		grp.add(_ammoText);
		var flashIcon:FlxSprite = new FlxSprite(UI_X, UI_Y+1);
		flashIcon.loadGraphic(FileReg.uiFlashlightIcon, false, 14, 14, false);
		flashIcon.scrollFactor.set(0, 0);
		grp.add(flashIcon);
		var healthIcon:FlxSprite = new FlxSprite(UI_X, UI_Y+19);
		healthIcon.loadGraphic(FileReg.uiHealthIcon, false, 14, 14, false);
		healthIcon.scrollFactor.set(0, 0);
		grp.add(healthIcon);
	}
	//Helper function to force the flashlight to turn off, also starts a flush of flashlight image on next frame (prevents flush before draw)
	public function forceLightOff() 
	{
		_flashLight.visible = false;
		_flashLightClear = true;
	}
	//Updates the ammo ui text
	function updateAmmoText() 
	{
		_ammoText.text = Std.string(_ammoInClip) + "/" + Std.string(_ammoOutOfClip);
	}
	//Clean several elements on level load to allow for changes in level (lights), also resets health to make game easier
	public function clean() {
		forceLightOff(); 
		health = 100;
		_lights = null;
	}
	//On death of player destroy and change to death screen
	override public function kill():Void 
	{
		super.kill();
		FlxG.camera.fade(FlxColor.BLACK, .66, false, function() {
			FlxG.log.add("player dead, swapping to end screen");
			FlxG.switchState(new EndGameState("You died.."));			//Swap state
		});
	}
	//Cleanup several UI elements on level load to allow them to be recreated on top with new ui camera (prevents zoom break)
	public function cleanup() {
		_flashlightBar = null;
		_healthBar = null;
		_ammoText = null;
	}
}