import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;

class Entity extends Object {
	inline static var gravity = 9;
	inline static var jumpForce = 80;
	inline static var moveForce = 15;

	var initPosition:Vector2D;
	var bmp:Bitmap;
	var actions:Array<Action> = new Array();
	var setJump:Map<Int, Bool> = new Map();
	var doubleJump:Bool;
	var onFloor:Bool;

	public var velocity:Vector2D;

	public var action:Action;

	public function new(x:Float = 0, y:Float = 0, ?parent:Object) {
		super(parent);
		var tile = Tile.fromColor(0xFFFFFFFF, 64, 64);
		alpha = 0.7;
		bmp = new Bitmap(tile, this);
		this.initPosition = new Vector2D(x, y);
		this.setPosition(x, y);
		this.velocity = new Vector2D(moveForce, 0);
		this.action = new Action();
		this.doubleJump = true;
		actions[0] = this.action;
	}

	public function saveAction(action:Action, tick:Int) {
		actions[tick] = action;
	}

	public function saveJump(tick:Int):Void {
		setJump[tick] = true;
	}

	public function playAction(tick:Int) {
		while (tick > 0 && actions[tick] == null) {
			tick--;
		}
		action = actions[tick];
		if (setJump.exists(tick) && setJump[tick]) {
			if (!onFloor) {
				if (doubleJump) {
					doubleJump = false;
				} else {
					return;
				}
			}
			velocity.y = -jumpForce;
			onFloor = false;
		}
	}

	public function update() {
		if (action.left) {
			x -= velocity.x;
		}
		if (action.right) {
			x += velocity.x;
		}
		y += velocity.y + gravity;
		velocity.y = Math.round(velocity.y / 2);
	}

	public function setGhost() {
		bmp.alpha = 0.5;
	}

	public function restart():Void {
		this.setPosition(initPosition.x, initPosition.y);
	}

	public function touchFloor() {
		onFloor = true;
		doubleJump = true;
	}
}