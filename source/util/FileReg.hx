package util;

/**
 * ...
 * @author Glynn Taylor
 */
class FileReg
{
	//Directory paths (add more for subdirs)//
	private static inline var sndPath:String = "assets/sounds/";
	private static inline var dataPath:String = "assets/data/";
	private static inline var imgPath:String = "assets/images/";
	private static inline var imgCharPath:String = imgPath+"character/";
	private static inline var imgMapPath:String = "assets/images/map/";
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
	public static inline var sndStep:String = sndPath + "step.wav";
	public static inline var sndWin:String = sndPath + "win.wav";
	//IMAGES//
	public static inline var imgButton:String = imgPath + "button.png";
	public static inline var imgDecal:String = imgPath + "decaltiles.png";
	public static inline var imgGibs:String = imgPath + "gibs.png";
	public static inline var imgPlayer:String = imgCharPath + "player_female.png";
	//public static inline var imgTiles:String = imgPath + "tiles.png";
	public static inline var imgLight:String = imgMapPath + "light.png";
	//MAP//
	public static inline var mapTiles:String = imgMapPath + "tileset.png";
	public static inline var mapTilesBG:String = imgMapPath + "tileset_bg.png";
	//UI//
	public static inline var uiBtn:String = uiPath + "button.png";
	//DATA//
	public static inline var dataLevel_1:String = dataPath + "level_1.oel";
	
	//End.
	
}