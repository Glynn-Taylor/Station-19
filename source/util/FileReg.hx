package util;

/**
 * ...
 * @author Glynn Taylor
 */
class FileReg
{
	//Directory paths (add more for subdirs)//
	private static inline var sndPath:String = "assets/sounds/";
	private static inline var sndMonsterPath:String = "assets/sounds/monster/";
	private static inline var dataPath:String = "assets/data/";
	private static inline var imgPath:String = "assets/images/";
	private static inline var imgCharPath:String = imgPath+"character/";
	private static inline var imgMapPath:String = "assets/images/map/";
	private static inline var imgEntPath:String = "assets/images/entities/";
	private static inline var mscPath:String = "assets/music/";
	private static inline var uiPath:String = "assets/ui/";
	//MUSIC//
	public static inline var mscBG:String = mscPath + #if (flash) "bg1.mp3" #else "bg1.ogg" #end;
	public static inline var mscBG2:String = mscPath + #if (flash) "bg2.mp3" #else "bg2.ogg" #end;
	//SOUNDS//
	public static inline var sndHit:String = sndPath + "hit.wav";
	public static inline var sndFire:String = sndPath + "fire.wav";
	public static inline var sndPickup:String = sndPath + "pickup.wav";
	public static inline var sndSelect:String = sndPath + "select.wav";
	public static inline var sndToggle:String = sndPath + "button02.wav";
	public static inline var sndButton:String = sndPath + "button01.wav";
	public static inline var sndElevator:String = sndPath + "elevator.wav";
	public static inline var sndStep:String = sndPath + "step.wav";
	public static inline var sndWin:String = sndPath + "win.wav";
	public static inline var sndMPain1:String = sndMonsterPath + "pain1.wav";
	public static inline var sndMPain2:String = sndMonsterPath + "pain2.wav";
	public static inline var sndMDeath1:String = sndMonsterPath + "death1.wav";
	public static inline var sndWRifle:String = sndPath + "weapon/" + "cg1.wav";
	public static inline var sndWPistol:String = sndPath + "weapon/" + "pistol.wav";
	public static inline var sndWEmpty:String = sndPath + "weapon/" + "gun_empty.wav";
	public static inline var sndWReload:String = sndPath+"weapon/" + "pistol_reload.wav";
	//IMAGES//
	public static inline var imgButton:String = imgPath + "button.png";
	public static inline var imgDecal:String = imgPath + "decaltiles.png";
	public static inline var imgGibs:String = imgPath + "gibs.png";
	public static inline var imgMGibs:String = imgPath + "mgibs.png";
	public static inline var imgFlashlight:String = imgCharPath + "flashlight.png";
	public static inline var imgPlayer:String = imgCharPath + "player_female.png";

	public static inline var imgEnemies:String = imgCharPath + "enemies.png";
	public static inline var imgZombie:String = imgCharPath + "zombie.png";
	public static inline var imgSkeleton:String = imgCharPath + "skeleton.png";
	public static inline var imgPlayerMale:String = imgCharPath + "player_male.png";
	public static inline var imgPlayerNeutral:String = imgCharPath + "player_helmet.png";
	//public static inline var imgTiles:String = imgPath + "tiles.png";
	public static inline var imgLight:String = imgMapPath + "light.png";
	public static inline var imgDoor:String = imgEntPath + "door.png";
	public static inline var imgElevator:String = imgEntPath + "elevator.png";
	public static inline var imgEntButton:String = imgEntPath + "button.png";
	public static inline var imgChest:String = imgEntPath + "chest.png";
	public static inline var imgCupboard:String = imgEntPath + "cupboard.png";
	public static inline var imgSlider:String = uiPath + "slider.png";
	public static inline var imgSliderBG:String = uiPath + "slider_bg.png";
	//MAP//
	public static inline var mapTiles:String = imgMapPath + "tileset.png";
	public static inline var mapTilesBG:String = imgMapPath + "tileset_bg.png";
	//UI//
	public static inline var uiBtn:String = uiPath + "button.png";
	public static inline var uiFlashlightBar:String = uiPath + "flashlight_bar.png";
	public static inline var uiFlashlightIcon:String = uiPath + "flashlight_icon.png";
	public static inline var uiHealthIcon:String = uiPath + "health_icon.png";
	//DATA//
	public static inline var dataLevel_1:String = dataPath + "level_1.oel";
	
	//End.
	
}