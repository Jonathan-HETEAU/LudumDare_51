import h3d.col.Collider;
import h2d.col.RoundRect;
import h2d.Layers;
import haxe.ds.List;
import h2d.Object;
import h2d.Text;
import hxd.res.DefaultFont;
import hxd.Key;
import hxd.Event;
import hxd.Window;
import h2d.Bitmap;
import h2d.Tile;

class Action {
	public var right:Bool;
	public var left:Bool;

	public function new(left = false, right = false) {
		this.right = right;
		this.left = left;
	}

	public function copy():Action {
		return new Action(left, right);
	}
}

class Vector2D {
	public var x:Float;
	public var y:Float;

	public function new(x:Float = 0., y:Float = 0.) {
		this.x = x;
		this.y = y;
	}
}

class Entity extends Object {
	var initPosition:Vector2D;
	var bmp:Bitmap;
	var actions:Array<Action> = new Array();
	var setJump:Map<Int, Bool> = new Map();
	var velocity:Vector2D;

	public var action:Action;

	var collider:RoundRect;

	public function new(x:Float = 0, y:Float = 0, ?parent:Object) {
		super(parent);
		var tile = Tile.fromColor(0xFFFFFF, 64, 64);
		bmp = new Bitmap(tile, this);
		this.initPosition = new Vector2D(x, y);
		this.setPosition(x, y);
		this.velocity = new Vector2D();
		this.action = new Action();
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
	}

	public function setGhost() {
		bmp.alpha = 0.5;
	}

	public function restart():Void {
		this.setPosition(initPosition.x, initPosition.y);
	}
}

class Platforme extends Object {
	public var bitmap:Bitmap;

	public function new(x:Float, y:Float, width:Int = 0, height:Int = 0, ?parent:Object) {
		super(parent);
		setPosition(x, y);
		var tile = Tile.fromColor(0x48FF00, width, height);
		bitmap = new Bitmap(tile, this);
	}
}

class Main extends hxd.App {
	inline static var delay:Float = 0.2;
	inline static var tickPerSec:Float = 50;
	inline static var entitiesNbr:Int = 2;

	var timeText:h2d.Text;
	var time:Float;
	var tick:Int;

	var play:Bool = false;
	var arena:Layers;
	var level:Layers;
	var entity:Entity;
	var entities:List<Entity> = new List<Entity>();
	var plateformes:List<Platforme> = new List<Platforme>();

	var action:Action = new Action();
	var jump:Bool = false;

	override function init() {
		hxd.Window.getInstance().title = "TimeStick";
		s2d.addEventListener(onEvent);
		initTimer();
		initUI();
		level = new Layers(s2d);
		arena = new Layers(s2d);
		entity = new Entity(s2d.width * 0.5, s2d.height * 0.5, arena);
		plateformes.add(new Platforme(s2d.width * 0.25, s2d.height * 0.5, 64, 64, level));
		plateformes.add(new Platforme(s2d.width * 0.75, s2d.height * 0.5, 64, 64, level));
	}

	private function initTimer() {
		time = 0.;
		tick = 0;
	}

	private function initUI() {
		var font = DefaultFont.get();
		timeText = new Text(font, s2d);
		timeText.x = s2d.width * 0.5;
	}

	override function update(deltat:Float) {
		super.update(deltat);
		if (play) {
			time += deltat;
			var newTick = Std.int(Math.abs(time * tickPerSec));
			if (newTick > this.tick) {
				for (i in 0...(newTick - this.tick)) {
					this.tick += 1;
					if (this.tick >= 500) {
						onTen();
					}
					fixedUpdate(this.tick);
				}
			}
		}
		timeText.text = "" + time + "| tick:" + tick;
	}

	function onTen() {
		this.tick = 0;
		this.time = this.time % delay;
		this.entity.setGhost();
		this.entities.add(entity);

		if (this.entities.length > entitiesNbr) {
			this.entities.pop().remove();
		}
		for (entity in this.entities) {
			entity.restart();
		}
		this.entity = new Entity(s2d.width * 0.5, s2d.height * 0.5, arena);
	}

	function fixedUpdate(tick:Int) {
		updateEntities(tick);
		updateEntity(tick);
	}

	function updateEntities(tick:Int) {
		for (entity in entities) {
			entity.playAction(tick);
			resolveAction(entity);
		}
	}

	function updateEntity(tick:Int) {
		entity.saveAction(action.copy(), tick);
		if (jump)
			entity.saveJump(tick);
		entity.playAction(tick);
		resolveAction(entity);
	}

	function resolveAction(entity:Entity) {
		if (entity.action.left) {
			entity.x -= 20;
		}
		if (entity.action.right) {
			entity.x += 20;
		}
		for (plateforme in plateformes) {
			var eBounds = entity.getBounds();
			var bounds = plateforme.getBounds();
			var boundsInterseption = eBounds.intersection(bounds);
			trace("inter " + boundsInterseption.x + ":" + boundsInterseption.width + " entity" + eBounds);
			if (entity.x < plateforme.x) {
				entity.x -= boundsInterseption.width;
			} else {
				entity.x += boundsInterseption.width;
			}
		}
	}

	function onEvent(event:Event) {
		switch (event.kind) {
			case EKeyUp:
				switch (event.keyCode) {
					case hxd.Key.RIGHT:
						action.right = false;

					case hxd.Key.LEFT:
						action.left = false;
					case hxd.Key.UP:

					case hxd.Key.SPACE:
						play = !play;
					case _:
				}
			case EKeyDown:
				switch (event.keyCode) {
					case hxd.Key.RIGHT:
						action.right = true;
					case hxd.Key.LEFT:
						action.left = true;
					case hxd.Key.UP:
					case _:
				}
			case _:
		}
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main();
	}
}