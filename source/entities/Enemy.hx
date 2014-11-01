package entities;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxRandom;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import player.Player;
import util.FileReg;

/**
 * @author Glynn Taylor
 * Base enemy class, could be abstracted more to support non left/right facing enemies
 */
class Enemy extends FlxSprite
{
	private var _gibs:FlxEmitter;						//Gibs for death
	private var _frontBumper:FlxSprite;					//Bumper for player detection (raycasting not working)
	private var _trackingText:FlxText;					//Text above to display if seen player
	private var _player:Player;							//Player to check when tracking
	private var _trackingPlayer:Bool = false;			//Whether or no is following player
	private var _unkillable:Bool = false;				//Can be killed or simply disabled
	private var _healthy:Bool = true;					//If disabled or not
	private var _canAttack:Bool = true;					//Bool to track if has attacked recently
	private var _lastSeen:Int;							//Tracks when player went missing from sight
	private var _damage:Float = 5;						//How much damage to do when attacking
	private static inline var BUMPER_LENGTH = 80;		
	private static inline var IGNORE_MS:Int = 3500;		//Time until stops hunting player after losing sight
	private var MAX_HEALTH:Float;
	//CONSTRUCTOR//
	public function new(xPosition:Float, yPosition:Float, hp:Float, killable:Bool):Void {
		super(xPosition, yPosition);
		_unkillable = !killable;
		health = hp;
		MAX_HEALTH = hp;
		_frontBumper = new FlxSprite(x, y);
		_frontBumper.makeGraphic(BUMPER_LENGTH, 5, 0x00000000, false);
		_trackingText = new FlxText(x, y, 10, "", 8, true);
		FlxG.state.add(_frontBumper);
		FlxG.state.add(_trackingText);
		
	}
	//Checks if bumper overlaps if not tracking
	public function checkBumper (player:Player, tiles:FlxTilemap):Void {
		//If not tracking, player in sight/bumper, 
		if (!_trackingPlayer && _frontBumper.overlaps(player) && !player._isHidden && _healthy) {
			//Raycasting would be better as to avoid sight going through walls, but seems to be not working in HaxeFlixel atm
			//---Raycasting broken for some reason, rect pseudo ray used instead---//
			/*if(tiles.ray(new FlxPoint(_frontBumper.x,_frontBumper.y),new FlxPoint(_player.x,_frontBumper.y),8)){
				alert(player);
				FlxG.log.add("enemy sees player");
			}else {
				FlxG.log.add("enemy sees wall in way of player");
			}*/
			alert(player);
		}
	}
	//Alert when sees player (front bumper overlap)
	public function alert (player:Player):Void {
			_player = player;
			_trackingPlayer = true;
			_trackingText.text = "!";
	}
	//Stops tracking player
	public function standDown ():Void {
			_trackingPlayer = false;
			_trackingText.text = "";
	}
	
	override public function hurt(Damage:Float):Void 
	{
		//If not knocked down
		if(_healthy){
			if (facing == FlxObject.RIGHT) 
			{
				// Knock Enemy on hit
				velocity.x = drag.x * 4; 
			}
			else if (facing == FlxObject.LEFT) 
			{
				velocity.x = -drag.x * 4;
			}
		
			FlxSpriteUtil.flicker(this, 0.5);	//Hit flicker
			FlxG.sound.play(FlxRandom.chanceRoll()?FileReg.sndMPain1:FileReg.sndMPain2, 1, false); //Play one of two hurt sounds
			super.hurt(Damage);					//Decrease health
		}
	}
	//On death function
	override public function kill():Void 
	{
		if (!_unkillable) {
			//Emit gib particles
			if (_gibs != null)
			{	
				_gibs.at(this);
				_gibs.start(true, 2.80);
				FlxG.sound.play(FileReg.sndMDeath1, 1, false);
			}
			//Kill extra stuff
			_frontBumper.kill();
			_trackingText.kill();
			super.kill();
		}else { //If cant be killed then disable
			animation.play("recovering");
			health = MAX_HEALTH;
			_healthy = false;
			standDown();			//Stop tracking player
			new FlxTimer(3, setHealthy, 1);
		}
	}
	//Reenables an unkillable enemy after has been dead
	private function setHealthy(timer:FlxTimer) {
		_healthy = true;
		animation.play("move");
	}
	//Set the damage of the enemy
	public function setDamage(amount:Float) {
		_damage = amount;
	}
	//Attack player if is tracking, has not attacked in a bit and is not disabled
	public function attackPlayer(player:Player) {
		if (_trackingPlayer&&_canAttack&&_healthy) {
				animation.play("attack");
				_canAttack = false;
				player.hurt(_damage);
				new FlxTimer(1.5, function(_) { _canAttack = true; }, 1);		//Reset can attack
				new FlxTimer(1, function(_) { animation.play("move"); }, 1);	//Start moving animation again
				FlxG.sound.play(FileReg.sndPlayerHurt, 1, false);
		}
	}
}