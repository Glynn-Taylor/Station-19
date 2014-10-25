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
    
    public function new(x:Float, y:Float, darkness:FlxSprite, scaling:Float):Void {
		
		super(x, y);
		loadGraphic(FileReg.imgLight, false, 64, 64);
		this.scale.set(scaling*1, scaling*1);
		//this.scale set;
		this.darkness = darkness;
		this.blend = BlendMode.SCREEN;
    }
	
    override public function draw():Void {
      var screenXY:FlxPoint = getScreenXY();
	  // blend = "screen";
	  try{
      darkness.stamp(this,
                    Math.floor(screenXY.x - this.width / 2),
                  Math.floor(screenXY.y - this.height / 2));
	  }catch (e:String) {
		  trace(screenXY.x - this.width / 2);
		  trace(e);
	  }
	  // blend = "overlay";
    }
}