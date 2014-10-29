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
import entities.TriggerText;
import entities.Useable;
import flixel.addons.display.FlxZoomCamera;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.addons.ui.FlxUIGroup;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import openfl.Assets;
import openfl.geom.Point;
import openfl.Lib;
import openfl.display.BlendMode;
import player.Player;
import player.TextDisplay;
import util.FileReg;
import util.Reg;
import util.ZoomCamera;

/**
 * ...
 * @author Glynn Taylor
 * The main game (play) state
 */
class PlayState extends FlxState
{
	//Constants
	private static inline var _ARROW_POOL_LIMIT:Int = 18; //Number of recyclable arrows, norm app is 3
	//Map var
	private var _map:FlxOgmoLoader;
	private var _mTiles:FlxTilemap;
	private var _mWalls:FlxTilemap;
	private var _mTilesInFront:FlxTilemap;
	private var _mTilesBehind:FlxTilemap;
	private var darkness:FlxSprite;
	//Group var
	public var _player:Player;
	public var _grpLight:FlxTypedGroup<Light>;
	public var _solidEnt:FlxTypedGroup<FlxSprite>;
	public var _useableEnt:FlxTypedGroup<Useable>;
	public var _grpTrigger:FlxTypedGroup<Triggerable>;
	public var _grpEnemies:FlxTypedGroup<Enemy>;
	//Emitter var
	private var _gibs:FlxEmitter;
	private var _mGibs:FlxEmitter;
	//Util var
	private var _sndHit:FlxSound;
	private var _sndPickup:FlxSound;
	private var _victoryString:String = "";				//Temp store for victory string to enable pause before state transistion
	private var _triggerMap:Map<Int,Triggerable> = new Map<Int,Triggerable>();
	//UI//
	private var _textDisplay:TextDisplay;
	private var guiCamera:FlxCamera;
	
	public function new() 
	{
		super();
	
		
	}
	
	//Initialisation
	override public function create():Void 
	{
		//LIGHTING//
		bgColor = 0xFF000000;
		_solidEnt = new FlxTypedGroup<FlxSprite>();
		_useableEnt = new FlxTypedGroup<Useable>();
		_grpLight = new FlxTypedGroup<Light>();
		_grpTrigger = new FlxTypedGroup<Triggerable>();
		_grpEnemies = new FlxTypedGroup<Enemy>();
		darkness = new FlxSprite(0,0);
		darkness.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
		darkness.scrollFactor.x = darkness.scrollFactor.y = 0;
		darkness.blend = BlendMode.MULTIPLY;
		
		_mGibs = new FlxEmitter();						//Create emitter for gibs
		_mGibs.setXSpeed( -150, 150);					//Gib settings
		_mGibs.setYSpeed( -200, 0);
		_mGibs.acceleration.y = 400;						//Add gravity to gibs
		_mGibs.setRotation( -720, 720);
		_mGibs.makeParticles(FileReg.imgMGibs, 25, 16, true, .5);	//Setup gib tilesheet
												//Add gibs to scene
		//MAP//
		_map = new FlxOgmoLoader(FileReg.dataLevel_1);	//Load level
		_mTiles = _map.loadTilemap(FileReg.mapTiles, 16, 16, "tiles");	//Load walls with tilesheet using tiles layer
		_mTiles.setTileProperties(1, FlxObject.NONE);	//Set tile 1 to be non collidable
		_mTiles.setTileProperties(2, FlxObject.ANY);	//Set tile 2 to be collidable, makes 2+ collidable too if not set further
		_mTiles.immovable = true;						//Ensure wall immovable (default)
		
		_mWalls = _map.loadTilemap(FileReg.mapTilesBG, 16, 16, "tiles_walls");	//Load map decals (after players so in front)
		_mWalls.setTileProperties(1, FlxObject.NONE);	//Set non collideable
		add(_mWalls);									//Add to scene
		
		_mTilesBehind = _map.loadTilemap(FileReg.mapTilesBG, 16, 16, "tiles_behind");	//Load map decals (after players so in front)
		_mTilesBehind .setTileProperties(1, FlxObject.NONE);	//Set non collideable
		add(_mTilesBehind );	
		add(_useableEnt);
		add(_solidEnt);
		_map.loadEntities(createEntities, "ent");	//Create spawning positions
		_map.loadEntities(createEntities, "ent_behind");	//Create spawning positions
		add(_mTiles);	
		_player.createFlashLight(darkness);
		
		//UTIL//
		FlxG.mouse.visible = false;						//Hide Cursor
		_sndHit = FlxG.sound.load(FileReg.sndHit);		//Load sound hit
		_sndPickup = FlxG.sound.load(FileReg.sndPickup);//Load sound pickup
		
		_gibs = new FlxEmitter();						//Create emitter for gibs
		_gibs.setXSpeed( -150, 150);					//Gib settings
		_gibs.setYSpeed( -200, 0);
		_gibs.acceleration.y = 400;						//Add gravity to gibs
		_gibs.setRotation( -720, 720);
		_gibs.makeParticles(FileReg.imgGibs, 25, 16, true, .5);	//Setup gib tilesheet
		add(_gibs);										//Add gibs to scene
		
		//MAP//
		_mTilesInFront = _map.loadTilemap(FileReg.mapTilesBG, 16, 16, "tiles_infront");	//Load map decals (after players so in front)
		_mTilesInFront.setTileProperties(1, FlxObject.NONE);	//Set non collideable
		add(_mTilesInFront);									//Add to scene
		
		add(_grpTrigger);
		add(_grpEnemies);
		add(_mGibs);
		add(_grpLight);
		add(darkness);
		
		
		
	
		
		FlxG.camera.fade(FlxColor.BLACK, .33, true);	//Fade camera in
		
		//lxG.camera.zoom = 2;
		//FlxG.camera.width = Std.int(FlxG.camera.width / 2);
		//FlxG.camera.height = Std.int(FlxG.camera.height / 2);
		//FlxG.camera.follow(_player, FlxCamera.STYLE_LOCKON,null,0);
		var zoomCam:ZoomCamera = new ZoomCamera();
		FlxG.cameras.reset( zoomCam);
		zoomCam.targetZoom = 2;
		FlxG.camera.follow(_player, FlxCamera.STYLE_LOCKON, null, 0);
		
		 guiCamera = new FlxCamera(0, 0, 480, 320, 1.0);
		FlxG.cameras.add(guiCamera);
		var _gui:FlxUIGroup = new FlxUIGroup();
		
		_player.addUI(_gui);
		_textDisplay = new TextDisplay(380 , 0, 100,8);
		_gui.add(_textDisplay);
		
		add(_gui);
		_gui.cameras = new Array<FlxCamera>();
		_gui.cameras.push(guiCamera);
		FlxCamera.defaultCameras.remove(guiCamera);
		//FlxG.cameras.remove(guiCamera, true);
		super.create();
	}
	
	//Run every Frame
	override public function update():Void 
	{
		super.update();
		FlxG.overlap( _useableEnt, _player, useEnt);
		FlxG.overlap( _grpTrigger,_player, triggerTrig);
		FlxG.overlap(_player._rifle.group, _grpEnemies, hurtEnemy);
		
		FlxG.collide(_gibs, _mTiles);					//Check gibs vs walls collision
		FlxG.collide(_mGibs, _mTiles);
		FlxG.collide(_player._rifle.group, _solidEnt, destroyBullet);
		FlxG.collide(_player._rifle.group,_mTiles,destroyBullet);
		FlxG.collide(_solidEnt,_grpEnemies);	
		FlxG.collide(_solidEnt,_player);	
		FlxG.collide(_mTiles, _player);				//Check players vs walls collision
		FlxG.collide(_mTiles, _grpEnemies);	
		for (enemy in _grpEnemies) {
			enemy.checkBumper(_player, _mTiles);
		}
	}
	override public function draw():Void {
		FlxSpriteUtil.fill(darkness, 0xff000000);
		guiCamera.fill(0x00000000, false, 1);
		super.draw();
	}
	
	//Ends the game and transitions to new state with victory string
	private function endGame(Timer:FlxTimer):Void
	{
		FlxG.camera.fade(FlxColor.BLACK, .66, false, function() {	//Fade out
			FlxG.switchState(new EndGameState(_victoryString));	//Switch state
		});
	}
	
	
	//Get all of the spawn positions from the oel
	private function createEntities(entityName:String, entityData:Xml):Void
	{
		if (entityName == "spawn_player")						//If a spawn position
		{
			if(_player==null){
				_player = new Player(FlxG.width / 2 - 5, 30,"");	//Position changed on next line, stores pID and colour
				//_player.dirty = true;
			}
			var x:Int = Std.parseInt(entityData.get("x"));
			var y:Int = Std.parseInt(entityData.get("y"));
			_player.setPosition(x, y);
			add(_player);
		}
		else if (entityName == "ent_light")						//If a spawn position
		{
		
			var x:Int = Std.parseInt(entityData.get("x"));
			var y:Int = Std.parseInt(entityData.get("y"));
			var _light:Light = new Light(x, y,darkness, Std.parseFloat(entityData.get("Scale")));
			_light.color=(Std.parseInt("0x"+entityData.get("Color").substring(1)));
			//_light.color = Std.parseInt(entityData.get("Color"));
			_grpLight.add(_light);
		}
		else if (entityName == "ent_door")						//If a spawn position
		{
		
			var x:Int = Std.parseInt(entityData.get("x"));
			var y:Int = Std.parseInt(entityData.get("y"));
			//var _light:Light = new Light(x, y,darkness, Std.parseFloat(entityData.get("Scale")));
			var _door:Door = new Door(x, y);
			_triggerMap.set(Std.parseInt(entityData.get("door_id")),_door);
			_solidEnt.add(_door);
			FlxG.log.add("added door");
		}
		else if (entityName == "ent_elevator")						//If a spawn position
		{
			var x:Int = Std.parseInt(entityData.get("x"));
			var y:Int = Std.parseInt(entityData.get("y"));
			var p1:FlxPoint=null;
			var p2:FlxPoint=null;
			for ( child in entityData.elementsNamed("node") ) {
				if (p1 == null) {
					p1 = new FlxPoint(Std.parseInt(child.get("x")), Std.parseInt(child.get("y")));
				}else {
					p2 = new FlxPoint(Std.parseInt(child.get("x")), Std.parseInt(child.get("y")));
				}
			}
			var _ele:Elevator = new Elevator(x, y,p1,p2);
			_triggerMap.set(Std.parseInt(entityData.get("elevator_id")),_ele);
			_solidEnt.add(_ele);
			FlxG.log.add("added elevator");
		}
		else if (entityName == "ent_button")						//If a spawn position
		{
		
			var x:Int = Std.parseInt(entityData.get("x"));
			var y:Int = Std.parseInt(entityData.get("y"));
			//var _light:Light = new Light(x, y,darkness, Std.parseFloat(entityData.get("Scale")));
			var _btn:Button = new Button(x, y,Std.parseInt(entityData.get("button_id")));
			_useableEnt.add(_btn);
			FlxG.log.add("added button");
		}
		else if (entityName == "ent_chest")						//If a spawn position
		{
		
			var x:Int = Std.parseInt(entityData.get("x"));
			var y:Int = Std.parseInt(entityData.get("y"));
			//var _light:Light = new Light(x, y,darkness, Std.parseFloat(entityData.get("Scale")));
			var _chest:Chest = new Chest(x, y,Std.parseInt(entityData.get("ammo")));
			_useableEnt.add(_chest);
			FlxG.log.add("added chest with ammo: " +entityData.get("ammo"));
		}
		else if (entityName == "ent_hiding")						//If a spawn position
		{
		
			var x:Int = Std.parseInt(entityData.get("x"));
			var y:Int = Std.parseInt(entityData.get("y"));
			//var _light:Light = new Light(x, y,darkness, Std.parseFloat(entityData.get("Scale")));
			var _hiding:Hiding= new Hiding(x, y);
			_useableEnt.add(_hiding);
		}
		else if (entityName == "trigger_text")						//If a spawn position
		{
		
			var x:Int = Std.parseInt(entityData.get("x"));
			var y:Int = Std.parseInt(entityData.get("y"));
			var w:Float = Std.parseFloat(entityData.get("width"));
			var h:Float = Std.parseFloat(entityData.get("height"));
			//var _light:Light = new Light(x, y,darkness, Std.parseFloat(entityData.get("Scale")));
			var _txtTrigger:TriggerText = new TriggerText(x,y,w,h,entityData.get("text"));
			_grpTrigger.add(_txtTrigger);
			FlxG.log.add("added text trigger");
		}
		else if (entityName == "trigger_ladder")						//If a spawn position
		{
		
			var x:Int = Std.parseInt(entityData.get("x"));
			var y:Int = Std.parseInt(entityData.get("y"));
			var w:Float = Std.parseFloat(entityData.get("width"));
			var h:Float = Std.parseFloat(entityData.get("height"));
			//var _light:Light = new Light(x, y,darkness, Std.parseFloat(entityData.get("Scale")));
			var _ladderTrigger:TriggerLadder = new TriggerLadder(x,y,w,h);
			_grpTrigger.add(_ladderTrigger);
			FlxG.log.add("added ladder");
		}
		else if (entityName == "spawn_zombie")						//If a spawn position
		{
		
			var x:Int = Std.parseInt(entityData.get("x"));
			var y:Int = Std.parseInt(entityData.get("y"));
			var _zomb:EnemyPatrol = new EnemyPatrol(x,y,20,_mGibs);
			_grpEnemies.add(_zomb);
			FlxG.log.add("added enemy zombie");
		}
		
	}
	//Updates the angle of the arrow after bounce (does not change bounding box/velocity just graphical)
	private function useEnt(ent:FlxObject, player:FlxObject):Void
	{
		if( FlxG.keys.anyPressed(["E"]))
		cast(ent, Useable).interact(_player,_triggerMap);					//Update angle of arrow after bounce
	}
	
		private function triggerTrig(ent:FlxObject, player:FlxObject):Void
	{
		if(cast(ent,Triggerable)._causeType=="text"){
			cast(ent, Triggerable).Trigger(_textDisplay);					//Update angle of arrow after bounce
		}else {
			cast(ent, Triggerable).Trigger(_player);
		}
	}
	private function hurtEnemy(bullet:FlxObject, enemy:FlxObject):Void
	{
		cast(enemy, Enemy).hurt(10);					//Update angle of arrow after bounce
		cast(enemy, Enemy).alert(_player);
		if (_player._isHidden)
			cast(enemy, Enemy).standDown();
		FlxG.log.add("hit enemy with bullet");
		bullet.kill();
	}
	private function destroyBullet(bullet:FlxObject, world:FlxObject):Void
	{
		bullet.kill();
	}
	
	//Cleanup
	override public function destroy():Void 
	{
		super.destroy();
		_map = null;
		_mTiles = FlxDestroyUtil.destroy(_mTiles);
		_mWalls= FlxDestroyUtil.destroy(_mWalls);
		_mTilesBehind = FlxDestroyUtil.destroy(_mTilesBehind);
		_mTilesInFront= FlxDestroyUtil.destroy(_mTilesInFront);
		_player= FlxDestroyUtil.destroy(_player);
		_gibs= FlxDestroyUtil.destroy(_gibs);
		_sndHit= FlxDestroyUtil.destroy(_sndHit);
		_sndPickup= FlxDestroyUtil.destroy(_sndPickup);
		_victoryString = null;	
		FlxG.camera.zoom = 1;
	}
	
}