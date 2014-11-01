package state ; 
import entities.Button;
import entities.Chest;
import entities.Door;
import entities.Elevator;
import entities.Enemy;
import entities.EnemyPatrol;
import entities.Hiding;
import entities.Light;
import entities.Triggerable;
import entities.TriggerLadder;
import entities.TriggerLevel;
import entities.TriggerText;
import entities.Useable;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.addons.ui.FlxUIGroup;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;
import openfl.display.BlendMode;
import player.Player;
import player.TextDisplay;
import util.FileReg;
import util.ZoomCamera;

/**
 * ...
 * @author Glynn Taylor
 * The main gameplay state; a level loader and collision handler
 */
class PlayState extends FlxState
{
	//Constants
	private var CREEPY_MUSIC:Array<String> = [FileReg.mscCreepy1];	//Ambience
	//Map var
	private var _map:FlxOgmoLoader;									//Ogmo map
	private var _mTiles:FlxTilemap;									//Collideable tiles
	private var _mWalls:FlxTilemap;									//Background wall
	private var _mTilesInFront:FlxTilemap;							//Background in front of player
	private var _mTilesBehind:FlxTilemap;			
	private var darkness:FlxSprite;									//Lighting sprite
	//Group var
	public var _player:Player;
	public var _grpLight:FlxTypedGroup<Light>;
	public var _solidEnt:FlxTypedGroup<FlxSprite>;					//Collideable entities like doors
	public var _useableEnt:FlxTypedGroup<Useable>;					//Background useable entities like buttons
	public var _grpTrigger:FlxTypedGroup<Triggerable>;
	public var _grpEnemies:FlxTypedGroup<Enemy>;
	public var _levelTrigger:TriggerLevel;							//Trigger for next level loading
	//Emitter var
	private var _mGibs:FlxEmitter;
	//Util var
	private var _triggerMap:Map<Int,Triggerable> = new Map<Int,Triggerable>();//Maps e.g. buttons to doors/elevators
	private var _creepyMusic:FlxSound;								//More background ambience
	//UI//
	private var _textDisplay:TextDisplay;							//Displays text prompts
	private var guiCamera:FlxCamera;								//GUI camera (not scaled)
	private var _gui:FlxUIGroup;									//Group for ui camera
	
	//Initialisation
	override public function create():Void 
	{
		super.create();
		//Initial SETUP
		bgColor = 0xFF000000;
		_solidEnt = new FlxTypedGroup<FlxSprite>();
		_useableEnt = new FlxTypedGroup<Useable>();
		_grpLight = new FlxTypedGroup<Light>();
		_grpTrigger = new FlxTypedGroup<Triggerable>();
		_grpEnemies = new FlxTypedGroup<Enemy>();
		darkness = new FlxSprite(0,0);
		
		//MONSTER GIBS//
		_mGibs = new FlxEmitter();							//Create emitter for gibs
		_mGibs.setXSpeed( -150, 150);						//Gib settings
		_mGibs.setYSpeed( -200, 0);
		_mGibs.acceleration.y = 400;						//Add gravity to gibs
		_mGibs.setRotation( -720, 720);
		_mGibs.makeParticles(FileReg.imgMGibs, 25, 16, true, .5);	//Setup gib tilesheet
		
		//LOAD MAP//
		loadLevel(1);
		
		new FlxTimer(3, randomGroan, 0);		//Monster random ambience updates
		new FlxTimer(30, checkMusic, 0);		//Ambience updates
	}
	
	//Run every Frame
	override public function update():Void 
	{
		super.update();
		//INTERACTIONS//
		FlxG.overlap( _useableEnt, _player, useEnt);
		FlxG.overlap( _grpTrigger,_player, triggerTrig);
		FlxG.overlap(_player._rifle.group, _grpEnemies, hurtEnemy);
		FlxG.overlap(_player, _grpEnemies, hurtPlayer);
		//LEVEL CHANGES//
		if(_levelTrigger!=null){
			FlxG.overlap(_player, _levelTrigger, changeLevel);
		}else {
			FlxG.camera.fade(FlxColor.BLACK, .66, false, function() {	//Fade out
				FlxG.switchState(new EndGameState("You escaped!"));	//Switch state
			});
		}
		//COLLISIONS
		FlxG.collide(_mGibs, _mTiles);
		FlxG.collide(_player._rifle.group, _solidEnt, destroyBullet);
		FlxG.collide(_player._rifle.group,_mTiles,destroyBullet);
		FlxG.collide(_solidEnt,_grpEnemies);	
		FlxG.collide(_solidEnt,_player);	
		FlxG.collide(_mTiles, _player);
		FlxG.collide(_mTiles, _grpEnemies);	
		//AI//
		for (enemy in _grpEnemies) {
			enemy.checkBumper(_player, _mTiles);
		}
	}
	//Get all of the entity data from the oel
	private function createEntities(entityName:String, entityData:Xml):Void
	{
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "spawn_player")						//If player data
		{
			if(_player==null){
				_player = new Player(FlxG.width / 2 - 5, 30,"");	//Position changed on next line, stores pID and colour
			}
			//Set player position
			_player.reset(x, y);
			_player.velocity.set(0, 0);
			_player.setPosition(x, y);
			add(_player);
		}
		else if (entityName == "ent_light")						//If light data
		{
			//Stamp onto darknes overlay
			var _light:Light = new Light(x, y,darkness, Std.parseFloat(entityData.get("Scale")),(Std.parseInt("0x" + entityData.get("Color").substring(1))));
			_light.finalise();
			_grpLight.add(_light);								//Keep track of for player light
		}
		else if (entityName == "ent_door")						//If door data
		{
			var _door:Door = new Door(x, y);
			if (_triggerMap.exists(Std.parseInt(entityData.get("door_id"))))
				FlxG.log.add("DOOR ID CLASH: "+entityData.get("door_id"));			//Debug
			_triggerMap.set(Std.parseInt(entityData.get("door_id")), _door);		//Create association
			_solidEnt.add(_door);
			FlxG.log.add("added door");
		}
		else if (entityName == "ent_elevator")						//If elevator data
		{
			var p1:FlxPoint=null;
			var p2:FlxPoint = null;
			//Get top and bottom points
			for ( child in entityData.elementsNamed("node") ) {
				if (p1 == null) {
					p1 = new FlxPoint(Std.parseInt(child.get("x")), Std.parseInt(child.get("y")));
				}else {
					p2 = new FlxPoint(Std.parseInt(child.get("x")), Std.parseInt(child.get("y")));
				}
			}
			var _ele:Elevator = new Elevator(x, y, p1, p2);
			if (_triggerMap.exists(Std.parseInt(entityData.get("elevator_id"))))
				FlxG.log.add("ELEVATOR ID CLASH: "+entityData.get("elevator_id"));	//Debug
			_triggerMap.set(Std.parseInt(entityData.get("elevator_id")),_ele);		//Create association
			_solidEnt.add(_ele);
			FlxG.log.add("added elevator");
		}
		else if (entityName == "ent_button")						//If button data
		{
			var _btn:Button = new Button(x, y,Std.parseInt(entityData.get("button_id")));	//Create button
			_useableEnt.add(_btn);
			FlxG.log.add("added button");
		}
		else if (entityName == "ent_chest")						//If chest data
		{
			var _chest:Chest = new Chest(x, y,Std.parseInt(entityData.get("ammo")));		//Create chest with ammo val
			_useableEnt.add(_chest);
			FlxG.log.add("added chest with ammo: " +entityData.get("ammo"));
		}
		else if (entityName == "ent_hiding")						//If a hiding spot data
		{
			var _hiding:Hiding= new Hiding(x, y);					//Create hiding spot
			_useableEnt.add(_hiding);
		}
		else if (entityName == "trigger_text")						//If a text trigger
		{
			var w:Float = Std.parseFloat(entityData.get("width"));
			var h:Float = Std.parseFloat(entityData.get("height"));
			var _txtTrigger:TriggerText = new TriggerText(x,y,w,h,entityData.get("text"));	//Create trigger with text
			_grpTrigger.add(_txtTrigger);
			FlxG.log.add("added text trigger");
		}
		else if (entityName == "trigger_level")						//If a level trigger
		{
			var w:Float = Std.parseFloat(entityData.get("width"));
			var h:Float = Std.parseFloat(entityData.get("height"));
			_levelTrigger = new TriggerLevel(x, y, w, h, Std.parseInt(entityData.get("level_id")));	//Set the level trigger
			add(_levelTrigger);
			FlxG.log.add("added level trigger");
		}
		else if (entityName == "trigger_ladder")						//If a ladder
		{
			var w:Float = Std.parseFloat(entityData.get("width"));
			var h:Float = Std.parseFloat(entityData.get("height"));
			var _ladderTrigger:TriggerLadder = new TriggerLadder(x,y,w,h);	//Create a ladder
			_grpTrigger.add(_ladderTrigger);
			FlxG.log.add("added ladder");
		}
		else if (entityName == "spawn_zombie")						//If a zombie spawn
		{
			var _zomb:EnemyPatrol = new EnemyPatrol(x,y,20,_mGibs,FileReg.imgZombie,true);
			_grpEnemies.add(_zomb);
			_zomb.animation.add("attack", [3, 4, 5], 4, false);		//Set animation up
			FlxG.log.add("added enemy zombie");
		}
		else if (entityName == "spawn_skeleton")						//If a ekeleton spawn
		{
			var _skele:EnemyPatrol = new EnemyPatrol(x,y,20,_mGibs,FileReg.imgSkeleton,false);
			_grpEnemies.add(_skele);
			_skele.animation.add("attack", [3, 4, 5], 4, false);		//Set animations up
			_skele.animation.add("recovering", [6, 7, 8], 4, false);
			_skele.setDamage(15);										//Change damage
			FlxG.log.add("added enemy skeleton");
		}
	}
	//Deals with Interact key presses (E)
	private function useEnt(ent:FlxObject, player:FlxObject):Void
	{
		if( FlxG.keys.anyPressed(["E"]))
		cast(ent, Useable).interact(_player,_triggerMap);					//Calls interact on object
	}
	//Deals with walking into different triggers
	private function triggerTrig(ent:FlxObject, player:FlxObject):Void
	{
		if(cast(ent,Triggerable)._causeType=="text"){
			cast(ent, Triggerable).Trigger(_textDisplay);					//Different thing to effect for text trigger
		}else {
			cast(ent, Triggerable).Trigger(_player);						//Otherwise effect player
		}
	}
	//Deals with bullet->Enemy collision
	private function hurtEnemy(bullet:FlxObject, enemy:FlxObject):Void
	{
		cast(enemy, Enemy).hurt(10);
		cast(enemy, Enemy).alert(_player);				//Enemy alerted that player hit it
		if (_player._isHidden)							//If player fires then hides dont chase
			cast(enemy, Enemy).standDown();
		FlxG.log.add("hit enemy with bullet");
		bullet.kill();									//Destroy the bullet
	}
	//Damage player call
	private function hurtPlayer(player:FlxObject, enemy:FlxObject):Void
	{
		cast(enemy, Enemy).attackPlayer(_player);
		FlxG.log.add("player got hit");
	}
	//Helper function for kill collisions
	private function destroyBullet(bullet:FlxObject, world:FlxObject):Void
	{
		bullet.kill();
	}
	//Randomly causes an enemy to groan somewhere on the map
	private function randomGroan(timer:FlxTimer) {
		for(enemy in _grpEnemies){
		if (FlxRandom.intRanged(0, _grpEnemies.length - 1) == 0) {							//Random if will groan
			FlxG.sound.play(FileReg.sndMGroan).proximity(enemy.x, enemy.y, _player, 160);	//Groan in proxim
			break;
		}
		}
	}
	//Check if need to play more creepy ambienceon top of stuff
	private function checkMusic(timer:FlxTimer) {
		if (_creepyMusic != null) {
			if (!_creepyMusic.playing) {
				_creepyMusic = FlxG.sound.play(CREEPY_MUSIC[FlxRandom.intRanged(0, CREEPY_MUSIC.length - 1)], 0.5, false);
			}
		}else {
			_creepyMusic = FlxG.sound.play(CREEPY_MUSIC[FlxRandom.intRanged(0, CREEPY_MUSIC.length - 1)], 0.5, false);
		}
	}
	//Helper function for level trigger collision
	private function changeLevel(a:FlxObject, b:FlxObject):Void
	{
		loadLevel(_levelTrigger._id);	
	}
	//Cleans up groups
	private function cleanGroups() {
		
		_solidEnt.clear();
		_useableEnt.clear();
		_grpLight.clear();
		_grpTrigger.clear();
		_grpEnemies = new FlxTypedGroup<Enemy>();
		_triggerMap = new Map<Int,Triggerable>();
		remove(_levelTrigger);
		_levelTrigger = null;
		remove(_mWalls);
		remove(_mTilesBehind);
		remove(_useableEnt);
		remove(_solidEnt);
		remove(_mTiles);
		remove(_player);
		remove(_mTilesInFront);
		remove(_grpTrigger);
		remove(_grpEnemies);
		remove(_mGibs);
		remove(_grpLight);
		remove(darkness);
		_player.clean();
		darkness.makeGraphic(Math.floor(FlxG.worldBounds.width), Math.floor(FlxG.worldBounds.height), 0xff000000);
	}
	//Loads a level
	private function loadLevel(level_id:Int) {
		//MAP//
		if(level_id!=1)
			cleanGroups();								//Clean on non first level load
		_map = new FlxOgmoLoader(FileReg.dataLevel +Std.string(level_id)+".oel");	//Load level
		_mTiles = _map.loadTilemap(FileReg.mapTiles, 16, 16, "tiles");	//Load walls with tilesheet using tiles layer
		_mTiles.setTileProperties(1, FlxObject.NONE);	//Set tile 1 to be non collidable
		_mTiles.setTileProperties(2, FlxObject.ANY);	//Set tile 2 to be collidable, makes 2+ collidable too if not set further
		_mTiles.immovable = true;						//Ensure wall immovable (default)
		
		_mWalls = _map.loadTilemap(FileReg.mapTilesBG, 16, 16, "tiles_walls");	//Load map decals (after players so in front)
		_mWalls.setTileProperties(1, FlxObject.NONE);	//Set non collideable
		add(_mWalls);									//Add to scene
		
		//CREATE DARKNESS SPRITE//
		darkness.makeGraphic(Math.floor(FlxG.worldBounds.width), Math.floor(FlxG.worldBounds.height), 0xff000000);
		darkness.blend = BlendMode.MULTIPLY;
		
		_mTilesBehind = _map.loadTilemap(FileReg.mapTilesBG, 16, 16, "tiles_behind");	
		_mTilesBehind .setTileProperties(1, FlxObject.NONE);	//Set non collideable
		
		add(_mTilesBehind );
		add(_useableEnt);
		add(_solidEnt);
		_map.loadEntities(createEntities, "ent");	//Create entities
		_map.loadEntities(createEntities, "ent_behind");	//Create entities that dont collide with player
		add(_mTiles);	
		
		_player.createFlashLight(darkness);
		_player.trackLight(_grpLight);
		_player.makeWeapon();
		//UTIL//
		FlxG.mouse.visible = false;						//Hide Cursor
		//MAP//
		_mTilesInFront = _map.loadTilemap(FileReg.mapTilesBG, 16, 16, "tiles_infront");	//Load map decals (after players so in front)
		_mTilesInFront.setTileProperties(1, FlxObject.NONE);	//Set non collideable
		add(_mTilesInFront);									//Add to scene
		
		add(_grpTrigger);
		add(_grpEnemies);
		add(_mGibs);
		add(_grpLight);
		add(darkness);
		
		//Create new game camera
		var zoomCam:ZoomCamera = new ZoomCamera();
		FlxG.cameras.reset( zoomCam);							//Remove cameras in favour of new camera
	
		guiCamera = new FlxCamera(0, 0, 400, 300, 1);			//Create seperate GUI camera
		guiCamera.bgColor = 0x00000000;
		FlxG.cameras.add(guiCamera);
		_gui = new FlxUIGroup();								//Create a group to add the ui elements
		_player.addUI(_gui);									//Add player ui elements
		_textDisplay = new TextDisplay(300 , 0, 100,8);			//Add a renderer for text prompts
		_gui.add(_textDisplay);
		add(_gui);
		_gui.cameras=[guiCamera];								//Assign group to camera
		
		zoomCam.targetZoom = 1.75;
		FlxG.camera.follow(_player, FlxCamera.STYLE_LOCKON, null, 0);
		
		FlxCamera.defaultCameras = [zoomCam];					//Reset back to zoomcam
	
	}
	//Cleanup
	override public function destroy():Void 
	{
		_player.cleanup();
	}
	
}