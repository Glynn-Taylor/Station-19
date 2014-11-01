package entities;
import flixel.FlxSprite;
import openfl.display.BlendMode;
import util.FileReg;

/**
 * @author Glynn Taylor
 * Static light, stamps its "light" sprite onto the darkness overlay upon creation
 */
class Light extends FlxSprite {
    //CONSTRUCTOR
    public function new(x:Float, y:Float, darkness:FlxSprite, scaling:Float,col:Int=0xFFFFFFFF):Void {
		super(x, y);								//Set position
		loadGraphic(FileReg.imgLight, false, 64, 64);
		color = col;								//Set light color
		this.scale.set(scaling*1, scaling*1);		//Set size of light
		this.blend = BlendMode.SCREEN;
		try{
			darkness.stamp(this,
                    Math.floor(x),
                  Math.floor(y));					//Imprint the image on the darkness sprite
		}catch (e:String) {
			trace(e);
		}
    }
	
    override public function draw():Void {
		//Prevents further draw
    }
	public function finalise() {
		//Post stamping
	}
}