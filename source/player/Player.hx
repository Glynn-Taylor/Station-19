package player ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKeyboard;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import state.EndGameState;
import state.PlayState;
import util.FileReg;
import util.GamepadIDs;

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
	//Reference vars
	//Data vars
	private var _lastAngle:Float = 0;
	private var _hasFired:Bool = false;
	private var _hasDashed:Bool = false;
	private var _numArrows:Int = 3;
	//Sound vars
	private var _sndStep:FlxSound;
	private var _sndFire:FlxSound;
	//UI vars
	private var _ammoText:FlxText;
	
	//Constructor
	public function new(X:Float=0, Y:Float=0) 
	{											//Set player id (controller number)
		super(X, Y);
		loadGraphic(FileReg.imgPlayer, true, 32, 32);	//Load sprite
		setFacingFlip(FlxObject.LEFT, false, false);			//Assign flipping of animation based on "facing" variable
		setFacingFlip(FlxObject.RIGHT, true, false);			
		animation.add("d", [4, 4, 4, 4], 6, false);				//Assign frames to animation names
		animation.add("lr", [8, 9, 10, 11, 12, 13, 14, 15], 12, false);

		animation.add("u", [4, 4, 4, 4], 6, false);
		maxVelocity.set(80, 400);
		acceleration.y = 400;									//Setup gravity
		drag.x = maxVelocity.x * 10;
		scale.set(0.5, 0.75);
		
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
			}else if (acceleration.x < 0) {
				animation.play("lr");
				facing = FlxObject.LEFT;
			}else {
				animation.play("u");
			}
	}
	
	function keyboardMovement() 
	{
		var _up:Bool = FlxG.keys.anyPressed(["UP", "W","SPACEBAR"]);
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
}