package entities;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import util.FileReg;

class EnemyPatrol extends Enemy{

	public var directionX:Float;
	private var speedX:Float;

	public function new(xPosition:Float, yPosition:Float, sX:Float,gibs:FlxEmitter):Void {
		super(xPosition, yPosition,100);
		directionX = -1;
		speedX = sX;
		_gibs = gibs;
		loadGraphic(FileReg.imgZombie,true,21,32,true);
		animation.add("move",[0,1,2], Std.int(speedX/4)); // Use speed to set playback speed. Std.int() converts Float to Int needed by addAnimation
		animation.play("move");
		setFacingFlip(FlxObject.LEFT, false, false);			//Assign flipping of animation based on "facing" variable
		setFacingFlip(FlxObject.RIGHT, true, false);
	}

	override public function update():Void {
		if (_trackingPlayer) {
				if (_player.x < x)
			{
				// The sprite is facing the opposite direction than flixel is expecting, so hack it into the right direction
				directionX = -1; 
			}
			else if (_player.x > x)
			{
				directionX = 1;
			}
			if (!_frontBumper.overlaps(_player)) {
				if (_trackingText.text == "!")
				_trackingText.text = "?";
			}
		}else {
			if (touching==FlxObject.LEFT)
				directionX = 1;
			if (touching==FlxObject.RIGHT)
				directionX = -1;
		}
		_frontBumper.setPosition(x+10-(facing==FlxObject.LEFT?Enemy.BUMPER_LENGTH:0), y+16);
		_trackingText.setPosition(x+6, y-4);
		
		if(directionX == -1){
			facing = FlxObject.LEFT;
		}
		else{
			facing = FlxObject.RIGHT;
		}
		
		velocity.x = speedX * directionX;
		super.update();

	}
}