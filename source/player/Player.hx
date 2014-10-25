package player ;

import entities.Light;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKeyboard;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxColorUtil;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import state.EndGameState;
import state.PlayState;
import util.FileReg;
import util.GamepadIDs;
import util.Reg;

/**
 * ...
 * @author Glynn Taylor
 * Player sprite and logic
 */
class Player extends FlxSprite
{
	//Constant vars
	private static inline var SPEED:Float = 10;
	private static inline var DASH_SPEED:Float = 100;
	private static inline var FLASHLIGHT_X:Int = 71;
	private static inline var FLASHLIGHT_Y:Int = 10;
	//Reference vars
	//Data vars
	private var _lastAngle:Float = 0;
	private var _hasFired:Bool = false;
	private var _hasDashed:Bool = false;
	private var _numArrows:Int = 3;
	private var _flashLightEquipped:Bool = false;
	//Sound vars
	private var _sndStep:FlxSound;
	private var _sndFire:FlxSound;
	//UI vars
	private var _flashLight:Light;
	private var _ammoText:FlxText;
	//Original Color values//
	private var _hair:Array<Int> = [0xFFEFD074, 0xFFD58308, 0xFF824100];
	private var _hairGreyscale:Array<Int> = [0xFFCECECE, 0xFF8D8D8D, 0xFF4D4D4D];
	private var _armor:Array<Int> = [0xFFFFF200, 0xFFFFC90E];
	private var _armorGreyscale:Array<Int> = [0xFFDADADA, 0xFFC3C3C3];
	private var _skin:Array<Int> = [0xFFF6D5A4, 0xFFDE9462];
	private var _skinGreyscale:Array<Int> = [0xFFFFFFFF, 0xFFD4D4D4];
	
	private var _skinSwatch:Array<Int> = [0xFFF6D5A4, 0xFFF6D5A4, 0xFFCFAC84, 0xFFCFA97A, 0xFFC29369, 0xFFBA8960, 0xFFB57D58, 0xFFBD815C, 0xFFAA7651, 0xFFA87445, 0xFF8E5B3C, 0xFF845239, 0xFF7E4E37, 0xFF6B4532, 0xFF67452C, 0xFF502F1E, 0xFF573C27, 0xFF31221B];
	//Constructor
	public function new(X:Float=0, Y:Float=0,graphic:String) 
	{											//Set player id (controller number)
		super(X, Y);
		if(Reg.playerPixels==null||graphic!="")
			loadGraphic(graphic, true, 32, 32);	//Load sprite
		else
			loadGraphic(Reg.playerPixels, true, 32, 32);
		
		createAnimations();
		maxVelocity.set(80, 400);
		acceleration.y = 400;									//Setup gravity
		drag.x = maxVelocity.x * 10;
		setGameScale();
		
		//Bounding box
		width = 16;
		height = 24;
		//offset.x = 8;
		//offset.y = 16;
		centerOffsets();
		//Sounds
		_sndStep = FlxG.sound.load(FileReg.sndStep, 0.5, false);
		_sndFire = FlxG.sound.load(FileReg.sndFire, 1, false);
		
		//Setup UI
		_ammoText = new FlxText(0, 0,0, "|||", 5);
		_ammoText.color = 0xFFFFFF;
		_ammoText.alpha = 0.5;
		_ammoText.antialiasing = false;
		//FlxG.state.add(_ammoText);
	}
	public function setGameScale():Void {
		scale.set(0.5, 0.75);
	}
	public function createAnimations() {
		setFacingFlip(FlxObject.LEFT, false, false);			//Assign flipping of animation based on "facing" variable
		setFacingFlip(FlxObject.RIGHT, true, false);			
		animation.add("d", [4, 4, 4, 4], 6, false);				//Assign frames to animation names
		animation.add("lr", [8, 9, 10, 11, 12, 13, 14, 15], 12, false);
		animation.add("u", [4, 4, 4, 4], 6, false);
	}
	//Runs every frame
	override public function update():Void 
	{
		//_gamepad =FlxG.gamepads.getByID(_padID);				//Get pad
		acceleration.x = 0;
		
		keyboardMovement();
		keyboardButtons();
		
		updateAxis(GamepadIDs.LEFT_ANALOGUE_X, GamepadIDs.LEFT_ANALOGUE_Y);	//Movement and animation
		updateButtons();										//Jumping and firing
		
		checkAnimation();
		if (_flashLightEquipped)
			_flashLight.setPosition(this.x+FLASHLIGHT_X-(_flashLight.facing==FlxObject.LEFT?_flashLight.width:0), this.y+FLASHLIGHT_Y);
		//syncText();												//Sets ammo indicator position
		super.update();
		
		
	}
	
	function keyboardButtons() 
	{
		if(FlxG.keys.pressed.ESCAPE ){
			FlxG.camera.fade(FlxColor.BLACK, .66, false, function() {	//Fade out
				FlxG.switchState(new EndGameState("butts"));	//Switch state
			});
		}
	}
	
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
				animation.play("u");
			}
	}
	
	function keyboardMovement() 
	{
		var _up:Bool = FlxG.keys.anyPressed(["UP", "W"]);
		var _down:Bool = FlxG.keys.anyPressed(["DOWN", "S"]);
		var _left:Bool = FlxG.keys.anyPressed(["LEFT", "A"]);
		var _right:Bool = FlxG.keys.anyPressed(["RIGHT", "D"]);
		
		if (_left || _right) {
			acceleration.x = maxVelocity.x * 5*(_left?-1:1);			//Create x movement
		}
		if (_up && isTouching(FlxObject.FLOOR)) {
			velocity.y = -maxVelocity.y / 2;	
		}
	}

	//Sets ammo indicator position
	private function syncText() {
		_ammoText.x = x+10-(_ammoText.width);
		_ammoText.y = y-10;
	}
	//Movement and animation (checks buttons)
	private function updateButtons():Void {
		
		/*if ((_gamepad.pressed(GamepadIDs.A)||_gamepad.pressed(GamepadIDs.LogiA))&& isTouching(FlxObject.FLOOR))	//Test jump button and onfloor
			velocity.y = -maxVelocity.y / 2;					//Jump
			
		if ((_gamepad.pressed(GamepadIDs.X) || _gamepad.pressed(GamepadIDs.LogiX)) && !_hasFired && _numArrows > 0) {//Test fire button, antispam, has arrows
			//Firing//
			var arw:Arrow = cast(cast(FlxG.state , PlayState)._grpArrows.recycle(), Arrow);	//Recyle an new arrow (pulls a dead arrow from pool)
			arw.reset(x + (width - arw.width) / 2, y + (height - arw.height) / 2);	//Ressurect arrow with new position
			arw.degShoot(_lastAngle);							//Fire arrow with angle
			arw.color = color;
			_hasFired = true;									//Anti spam bool
			_numArrows--;										//Decrease ammo
			new FlxTimer(0.2, canFireAgain, 1);					//Timer to reset anti spam bool
			//UI-Sound//
			_ammoText.text= _ammoText.text.substr(0,_ammoText.text.length-1);
			_sndFire.play();
		}*/
	}
	//Resets anti arrow-spam bool
	private function canFireAgain(Timer:FlxTimer):Void
	{
		_hasFired = false;
	}
	//Resets anti dash-spam bool
	private function canDashAgain(Timer:FlxTimer):Void
	{
		_hasDashed = false;
	}
	//Handles movement and animation after checking controller stick
	private function updateAxis(xID:Int, yID:Int):Void
	{
		/*var xAxisValue = _gamepad.getXAxis(xID);				//Get x and y movement from controller stick
		var yAxisValue = _gamepad.getYAxis(yID);
		var angle:Float;
		
		if ((xAxisValue != 0) || (yAxisValue != 0))				//On movement
		{
			angle = Math.atan2(yAxisValue, xAxisValue);
			 _lastAngle = angle;
			var offsetx:Float = SPEED * Math.cos(angle);
			var offsety:Float = SPEED * Math.sin(angle);
			acceleration.x = maxVelocity.x * offsetx;			//Create x movement
			//Animation//
			if (acceleration.x > 0) {
				facing = FlxObject.RIGHT;						//Facing determines flipping
				animation.play("lr");
			}else if (acceleration.x < 0) {
				animation.play("lr");
				facing = FlxObject.LEFT;
			}
			_sndStep.play();
			_fireLine.angle = radToDeg(angle);					//Store angle for firing/fireline reference
			
			//DASHING WIP(Currently broken, y!=x)
			/*if (!_hasDashed&&_gamepad.pressed(GamepadIDs.B)) {
				velocity.x = DASH_SPEED * offsetx;
				velocity.y = DASH_SPEED * offsety;
				_hasDashed = true;
				new FlxTimer(1, canDashAgain, 1);
			}*/
		//}
	}
	//On death of player destroy UI too
	override public function kill():Void 
	{
		trace("am ded");
		_ammoText.kill();
		super.kill();
	}
	//Catch arrow (ammo++)
	public function restoreArrow():Void {
		_numArrows += 1;
		_ammoText.text += "|";
	}
	//Convert radians to degrees
	public inline static function radToDeg(rad:Float):Float
	{
		return 180 / Math.PI * rad;
	}
	//Cleanup
	override public function destroy():Void 
	{
		super.destroy();
		_sndFire = FlxDestroyUtil.destroy(_sndFire);
		_sndStep = FlxDestroyUtil.destroy(_sndStep);
		_ammoText= FlxDestroyUtil.destroy(_ammoText);
	}
	
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
	public function resetColorCache() {
		_hair = [0xFFEFD074, 0xFFD58308, 0xFF824100];
		_armor= [0xFFFFF200, 0xFFFFC90E];
		_skin= [0xFFF6D5A4, 0xFFDE9462];
	}
	public function createFlashLight(darkness:FlxSprite) {
		_flashLight = new Light(this.x, this.y, darkness, 1);
		_flashLight.loadGraphic(FileReg.imgFlashlight, false, 128, 32);
		_flashLight.setFacingFlip(FlxObject.LEFT, true, false);			//Assign flipping of animation based on "facing" variable
		_flashLight.setFacingFlip(FlxObject.RIGHT, false, false);	
		FlxG.state.add(_flashLight);
		_flashLightEquipped = true;
		_flashLight.facing = FlxObject.LEFT;
	}
}