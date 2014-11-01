package entities;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxObject;
import openfl.Lib;

/**
 * @author Glynn Taylor
 * Enemy patrol class, moves left and right and attacks player
 */
class EnemyPatrol extends Enemy{

	public var directionX:Float;	//Direction of movement in x, 1==right, -1==left
	private var speedX:Float;

	//CONTSTRUCTOR//
	public function new(xPosition:Float, yPosition:Float, sX:Float,gibs:FlxEmitter, sprite:String, killable:Bool):Void {
		super(xPosition, yPosition,100,killable);
		directionX = -1;
		speedX = sX;
		_gibs = gibs;
		loadGraphic(sprite,true,21,32,true);
		animation.add("move",[0,1,2], Std.int(speedX/4)); 		// Use speed to set playback speed
		animation.play("move");
		setFacingFlip(FlxObject.LEFT, false, false);			//Assign flipping of animation based on "facing" variable
		setFacingFlip(FlxObject.RIGHT, true, false);
		offset.x = 3;											//Set rough offsets for hitbox centering
		width = 15;
	}

	override public function update():Void {
		//If enabled then do update
		if(_healthy){
		if (_trackingPlayer) {
			//set move direction to be towards player
			directionX = _player.x > x?1: -1;
			if (!_frontBumper.overlaps(_player)) {	 //If can no longer see player
				if (_trackingText.text == "!"){
					_trackingText.text = "?";		//Show that have lost sight
					_lastSeen = Lib.getTimer();		//Setup timer to go back to patrolling
				}else {
					if (Lib.getTimer() >= _lastSeen + Enemy.IGNORE_MS)
						standDown();				//If have not seen player for IGNORE_MS, stop tracking
				}
			}else {
				if (_trackingText.text == "?"){
					_trackingText.text = "!";		//Show that have seen again
				}
			}
		}else {
			if (touching==FlxObject.LEFT)
				directionX = 1;						//Turn around if hit a wall
			if (touching==FlxObject.RIGHT)
				directionX = -1;
		}
		_frontBumper.setPosition(x+10-(facing==FlxObject.LEFT?Enemy.BUMPER_LENGTH:0), y+16);
		_trackingText.setPosition(x+6, y-4);		//Update text position and bumper position to be relative
		
		if(directionX == -1){
			facing = FlxObject.LEFT;				//Set facing based on move direction
		}
		else{
			facing = FlxObject.RIGHT;
		}
		
		velocity.x = speedX * directionX*(_trackingPlayer?1.5:1);//Move
		}
		super.update();

	}
}