import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;

class Platforme extends Object {
	public var bitmap:Bitmap;

	public function new(x:Float, y:Float, width:Int = 0, height:Int = 0, ?parent:Object) {
		super(parent);
		setPosition(x, y);
		var tile = Tile.fromColor(0x48FF00, width, height);
		bitmap = new Bitmap(tile, this);
	}
}