package player ;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import util.FileReg;

/**
 * @author Glynn Taylor
 * Flashlight that draws the light sprite when visible
 */
class FlashLight extends FlxSprite {

 
    private var darkness:FlxSprite;		//Darkness sprite
    private var backBuffer:BitmapData; 	//Copy of darkness pixels (lighting) before adding flashlight
	
    public function new(x:Float, y:Float, darkness:FlxSprite, scaling:Float):Void {
		
		super(x, y);
		loadGraphic(FileReg.imgLight, false, 64, 64);
		this.scale.set(scaling*1, scaling*1);			//Set size of flashlight
		this.darkness = darkness;
		backBuffer = darkness.pixels.clone();			//Create copy (lit scene overlay)
		this.blend = BlendMode.SCREEN;
    }
	
	//Called when flashlight equipped (.visible==true)
    override public function draw():Void {
		darkness.pixels = backBuffer.clone();		//Revert to original (slightly cheaper than making all lights dynamic)
		try{
			darkness.stamp(this, Math.floor(x),		//Stamp flashlight onto darkness
                  Math.floor(y));
		}catch (e:String) {
			trace(e);
		}
    }
	//Forces darkness to revert to non flashlight lit
	public function clear() {
		darkness.pixels = backBuffer.clone();		//Force clear on flashlight unequipped
	}

}