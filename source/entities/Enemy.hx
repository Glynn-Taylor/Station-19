package entities;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import player.Player;
import util.FileReg;

/**
 * ...
 * @author ...
 */
class Enemy extends FlxSprite
{
	private var _gibs:FlxEmitter;
	private var _frontBumper:FlxSprite;
	private var _trackingText:FlxText;
	private var _player:Player;
	private var _trackingPlayer:Bool = false;
	private var _unkillable:Bool = false;
	private var _healthy:Bool = true;
	private var _canAttack:Bool = true;
	private var _lastSeen:Int;
	private var _damage:Float = 10;
	private static inline var BUMPER_LENGTH = 80;
	private static inline var IGNORE_MS:Int = 3500;
	private var MAX_HEALTH:Float;
	
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
	public function checkBumper (player:Player, tiles:FlxTilemap):Void {
		if (!_trackingPlayer && _frontBumper.overlaps(player)&&!player._isHidden) {
			//---Raycasting broken for some reason---//
			/*if(tiles.ray(new FlxPoint(_frontBumper.x,_frontBumper.y),new FlxPoint(_player.x,_frontBumper.y),8)){
				alert(player);
				FlxG.log.add("enemy sees player");
			}else {
				FlxG.log.add("enemy sees wall in way of player");
			}*/
			alert(player);
		}
	}
	
	public function alert (player:Player):Void {
			_player = player;
			_trackingPlayer = true;
			_trackingText.text = "!";
	}
	public function standDown ():Void {
			_trackingPlayer = false;
			_trackingText.text = "";
	}
	
	override public function hurt(Damage:Float):Void 
	{
		if(_healthy){
		// remember, right means facing left
		if (facing == FlxObject.RIGHT) 
		{
			// Knock him to the right
			velocity.x = drag.x * 4; 
		}
		// Don't really need the if part, but hey.
		else if (facing == FlxObject.LEFT) 
		{
			velocity.x = -drag.x * 4;
		}
		
		FlxSpriteUtil.flicker(this, 0.5);
		FlxG.sound.play(FlxRandom.chanceRoll()?FileReg.sndMPain1:FileReg.sndMPain2, 1, false);
		super.hurt(Damage);
		}
	}
	
	override public function kill():Void 
	{
		if(!_unkillable){
			if (!alive) 
			{ 
				return; 
			}
		
			if (_gibs != null)
			{	
				_gibs.at(this);
				_gibs.start(true, 2.80);
				FlxG.sound.play(FileReg.sndMDeath1, 1, false);
			}
			_frontBumper.kill();
			_trackingText.kill();
			super.kill();
		}else {
			animation.play("recovering");
			health = MAX_HEALTH;
			_healthy = false;
			standDown();
			new FlxTimer(3, setHealthy, 1);
		}
	}
	private function setHealthy(timer:FlxTimer) {
		_healthy = true;
		animation.play("move");
	}
	private function setDamage(amount:Float) {
		_damage = amount;
	}
	
	public function attackPlayer(player:Player) {
		if (_trackingPlayer&&_canAttack) {
				animation.play("attack");
				_canAttack = false;
				new FlxTimer(1.5, function(_) { _canAttack = true; }, 1);
				new FlxTimer(1, function(_) { animation.play("move"); }, 1);
				player.hurt(_damage);
		}
	}
}