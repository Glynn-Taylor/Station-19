package player ;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import util.FileReg;

/**
 * ...
 * @author ...
 */
class FlashLight extends FlxSprite {

 
    private var darkness:FlxSprite;
    private var backBuffer:BitmapData;
	private var frontBuffer:BitmapData;
    public function new(x:Float, y:Float, darkness:FlxSprite, scaling:Float):Void {
		
		super(x, y);
		loadGraphic(FileReg.imgLight, false, 64, 64);
		this.scale.set(scaling*1, scaling*1);
		//this.scale set;
		this.darkness = darkness;
		backBuffer = darkness.pixels.clone();
		frontBuffer = darkness.pixels;
		this.blend = BlendMode.SCREEN;
    }
	
    override public function draw():Void {
		darkness.pixels = backBuffer.clone();
      var screenXY:FlxPoint = getScreenXY();
	  // blend = "screen";
	  try{
		darkness.stamp(this, Math.floor(x),
                  Math.floor(y));
	  }catch (e:String) {
		  trace(screenXY.x - this.width / 2);
		  trace(e);
	  }
	  // blend = "overlay";
    }
	
	public function clear() {
		darkness.pixels = backBuffer.clone();
	}

}