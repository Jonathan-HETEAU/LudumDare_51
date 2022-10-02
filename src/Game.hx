import h2d.Text;
import h2d.col.Bounds;
import h2d.Layers;
import h2d.Scene;
import Input;
import LdtkProject;
import hxd.res.DefaultFont;

class Game extends Scene {
	inline static var entitiesNbr:Int = 2;

	var input:Input;
	var level:Layer_Map;

	var start:Vector2D;
	var end:Bounds;
	var layersUI:Layers;
	var layersLevel:Layers;
	var layersEntity:Layers;

	var entity:Entity;
	var entities:List<Entity> = new List<Entity>();
	var plateformes:List<Platforme> = new List<Platforme>();

	var timer:Timer;
	var timeText:Text;

	public function new(level:Layer_Map) {
		super();
		this.level = level;
		this.input = new Input();
		this.addEventListener(input.onEvent);
		this.scaleMode = ScaleMode.LetterBox(level.cWid * level.gridSize, level.cHei * level.gridSize);
		init();
	}

	function init() {
		layersLevel = new Layers(this);
		layersEntity = new Layers(this);
		layersUI = new Layers(this);
		initTimer();
		initLevel();
		initEntities();
		entity = new Entity(start.x, start.y, layersEntity);
		initUI();
	}

	function initTimer() {
		timer = new Timer();
	}

	private function initUI() {
		timeText = new Text(DefaultFont.get(), layersUI);
		timeText.x = this.width * 0.5;
	}

	function initLevel() {
		while (plateformes.length > 0) {
			plateformes.pop().remove();
		}

		for (x in 0...level.cWid) {
			for (y in 0...level.cHei) {
				switch level.getInt(x, y) {
					case 1:
						plateformes.add(new Platforme(x * level.gridSize, y * level.gridSize, level.gridSize, level.gridSize, layersLevel));
					case 2:
						start = new Vector2D(x * level.gridSize + level.gridSize * 0.5, y * level.gridSize + level.gridSize * 0.5);
					case _:
				}
			}
		}
	}

	function initEntities() {
		while (entities.length > 0) {
			entities.pop().remove();
		}
		
	}

	

	public function update(deltat:Float) {
		if (input.play) {
			var tick = timer.getTick();
			timer.add(deltat);
			var newTick = timer.getTick();
			if (newTick > tick) {
				for (i in 0...(newTick - tick)) {
					tick += 1;
					if (tick >= 500) {
						onTen();
					}
					fixedUpdate(tick);
				}
			}
		}
		timeText.text = timer.toString();
	}

	function onTen() {
		this.entity.setGhost();
		this.entities.add(entity);
		if (this.entities.length > entitiesNbr) {
			this.entities.pop().remove();
		}
		
		timer.restart();
		for (entity in this.entities) {
			entity.restart();
		}
		entity = new Entity(start.x, start.y, layersEntity);
	}


	function fixedUpdate(tick:Int) {
		updateEntities(tick);
		updateEntity(tick);
		input.jump = false;
	}

	function updateEntities(tick:Int) {
		for (entity in entities) {
			entity.playAction(tick);
			entity.update();
			resolveAction(entity);
		}
	}

	function updateEntity(tick:Int) {
		entity.saveAction(input.action.copy(), tick);
		if (input.jump)
			entity.saveJump(tick);
		entity.playAction(tick);
		entity.update();
		resolveAction(entity);
	}

	function resolveAction(entity:Entity) {
		for (plateforme in plateformes) {
			var eBounds = entity.getBounds();
			var bounds = plateforme.getBounds();

			if (eBounds.intersects(bounds)) {
				var boundsInterseption = bounds.intersection(eBounds);
				entity.touchFloor();
				trace("intersect!!");
				trace("entity:" + eBounds);
				trace("plateforme:" + bounds);
				trace("boundsInterseption" + boundsInterseption);
				trace("width:" + boundsInterseption.width);
				trace("height:" + boundsInterseption.height);

				if (boundsInterseption.width >= boundsInterseption.height) {
					if (entity.y < plateforme.y) {
						entity.y -= boundsInterseption.height;
					} else {
						entity.y += boundsInterseption.height;
					}
				}
				if (boundsInterseption.width <= boundsInterseption.height) {
					if (entity.x < plateforme.x) {
						entity.x -= boundsInterseption.width;
					} else {
						entity.x += boundsInterseption.width;
					}
				}
			}
		}
	}
}
