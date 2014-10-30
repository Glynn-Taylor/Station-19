package entities;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import openfl.display.BlendMode;
import util.FileReg;

/**
 * ...
 * @author ...
 */
class Light extends FlxSprite {

 
    private var darkness:FlxSprite;
    
    public function new(x:Float, y:Float, darkness:FlxSprite, scaling:Float,col:Int=0xFFFFFFFF):Void {
		
		super(x, y);
		loadGraphic(FileReg.imgLight, false, 64, 64);
		color = col;
		this.scale.set(scaling*1, scaling*1);
		//this.scale set;
		this.darkness = darkness;
		this.blend = BlendMode.SCREEN;
		 var screenXY:FlxPoint = getScreenXY();
	  // blend = "screen";
	  try{
		darkness.stamp(this,
                    Math.floor(x),
                  Math.floor(y));
	  }catch (e:String) {
		  trace(screenXY.x - this.width / 2);
		  trace(e);
	  }
    }
	
    override public function draw():Void {
    
	  // blend = "overlay";
    }
	public function finalise() {
		 
	}
}