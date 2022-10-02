import h3d.scene.pbr.Environment.IrradLut;
import h2d.col.Point;
import h2d.Bitmap;
import h2d.Tile;
import h2d.TileGroup;
import h2d.Object;
import h2d.Text;
import h2d.col.Bounds;
import h2d.Layers;
import h2d.Scene;
import Input;
import LdtkProject;
import hxd.res.DefaultFont;

class ButtonLevel extends Bitmap {
	public var target:Activable;

	public function new(button:Entity_Button,cSize:Int,target:Activable,?parent:Object) {
		super(Tile.fromColor(0xFF0000,button.width,button.height),parent);
		setPosition(button.pixelX,button.pixelY);		
		this.target = target;
	}


}


interface Activable {
	public function activated():Void;
	public function desactivated():Void;
}

class MovingPlateforme extends Bitmap implements Activable {
	var path:Array<Point>;
	var indexPath:Int;
	var initPosition:Vector2D;
	var initState:Bool;
	var currentState:Bool;
	var loop:Bool;
	var sensLoop:Bool;
	var speed:Int;

	public function new(item:Entity_MovingPlateform, cSize:Int, ?parent:Object) {
		super(Tile.fromColor(0xFF00FF, item.width, item.height), parent);
		initPosition = new Vector2D(item.pixelX, item.pixelY);
		setPosition(initPosition.x, initPosition.y);
		this.currentState = this.initState = item.f_initState;
		this.loop = item.f_loop;
		speed = item.f_speed;
		path = item.f_parcours.map(p -> new Point(p.cx * cSize, p.cy * cSize));
		path.push(new Point(initPosition.x, initPosition.y));
	}

	public function update() {
		if (currentState) {
			updateDistance(speed);
		}
	}

	function updateDistance(speed:Float) {
		var nextPoint:Point = path[indexPath];
		var distance = Math.abs(getBounds().getMin().distance(nextPoint));
		if (distance <= speed) {
			setPosition(nextPoint.x,nextPoint.y);
			if (sensLoop) {
				indexPath++;
				if (indexPath >= path.length) {
					if (loop) {
						indexPath = path.length - 2;
						sensLoop = !sensLoop;
					}else{
						indexPath = path.length -1;
						return;
					}
				}
			} else {
				indexPath--;
				if (indexPath < 0) {
					if(loop){
					indexPath = 1;
					sensLoop = !sensLoop;
					}else{
						indexPath = 0;
						return;
					}
				}
			}
			updateDistance(speed - distance);
		}else{
			var target = nextPoint.sub(getBounds().getMin()).normalized().multiply(speed);
			setPosition(x+ target.x,y + target.y);
		}
	}

	public function activated() {
		currentState = !initState;
	}

	public function desactivated() {
		currentState = initState;
	}

	public function restart() {
		this.currentState = this.initState;
		this.indexPath = 0;
		this.sensLoop = true;
		this.setPosition(initPosition.x,initPosition.y);
	}
}

class SwitchingPlateforme extends Bitmap implements Activable{
	var initPosition:Vector2D;
	var initState:Bool;

	var currentState:Bool;

	public function new(item:Entity_SwitchPlateform, ?parent:Object) {
		super(Tile.fromColor(0xFFFFFF, item.width, item.height), parent);
		initPosition = new Vector2D(item.pixelX, item.pixelY);
		this.setPosition(initPosition.x, initPosition.y);
		this.currentState = this.initState = item.f_initState;
	}

	public function activated() {
		currentState = !initState;
	}

	public function desactivated() {
		currentState = initState;
	}

	public function update() {
		if (currentState) {
			this.alpha = 1;
		} else {
			this.alpha = 0.5;
		}
	}

	public function isSolid():Bool {
		return currentState;
	}

	public function restart() {
		currentState = initState;
		setPosition(initPosition.x, initPosition.y);
	}
}

class Game extends Scene {
	inline static var entitiesNbr:Int = 10;

	var input:Input;
	var level:LdtkProject_Level;

	var start:Vector2D;
	var end:Bitmap;
	var layersUI:Layers;
	var layersLevel:Layers;
	var layersEntity:Layers;

	var entity:Entity;
	var entities:List<Entity> = new List<Entity>();
	var plateformes:List<Platforme> = new List<Platforme>();
	var movingPlateformes:List<MovingPlateforme> = new List<MovingPlateforme>();
	var switchingPlateformes:List<SwitchingPlateforme> = new List<SwitchingPlateforme>();
	var buttons:List<ButtonLevel> = new List<ButtonLevel>();
	var mapIID:Map<String,Activable> = new Map();

	var timer:Timer;
	var timeText:Text;

	var gManager:GameManager;

	public function new(level:LdtkProject_Level,gManager:GameManager) {
		super();
		this.gManager = gManager;
		this.level = level;
		this.input = new Input();
		this.addEventListener(input.onEvent);
		this.scaleMode = ScaleMode.LetterBox(level.pxWid, level.pxHei);
		init();
	}

	function init() {
		layersLevel = new Layers(this);
		layersEntity = new Layers(this);
		layersUI = new Layers(this);
		initTimer();
		initMap(level.l_Map);
		initActivable(level.l_AcctivablePlateforme);
		initButton(level.l_Buttons);

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

	

	function initActivable(level:Layer_AcctivablePlateforme) {
		for (item in level.all_SwitchPlateform) {
			var obj = new SwitchingPlateforme(item, layersLevel); 
			switchingPlateformes.add(obj);
			mapIID.set(item.iid,obj);

		}

		for (item in level.all_MovingPlateform) {
			var obj = new MovingPlateforme(item,level.gridSize,layersLevel);
			movingPlateformes.add(obj);
			mapIID.set(item.iid,obj);
		}
	}

	function initButton(level:Layer_Buttons) {
		for (button in level.all_Button) {
			buttons.add(new ButtonLevel(button,level.gridSize,mapIID[button.f_target.entityIid],layersLevel ));
		}
	}


	function initMap(level:Layer_Map) {
		for (x in 0...level.cWid) {
			for (y in 0...level.cHei) {
				switch level.getName(x, y) {
					case "floor":
						plateformes.add(new Platforme(x * level.gridSize, y * level.gridSize, level.gridSize, level.gridSize, layersLevel));
					case "start":
						start = new Vector2D(x * level.gridSize, y * level.gridSize);
					case "end":
						end = new Bitmap(Tile.fromColor(level.getColorInt(x, y), level.gridSize, level.gridSize), layersLevel);
						end.setPosition(x * level.gridSize, y * level.gridSize);
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
		for (plateforme in switchingPlateformes) {
			plateforme.restart();
		}
		for (plateforme in movingPlateformes) {
			plateforme.restart();
		}
		entity = new Entity(start.x, start.y, layersEntity);
	}

	function fixedUpdate(tick:Int) {
		updateButtons();
		updatePlateforms(tick);
		updateEntities(tick);
		updateEntity(tick);
		input.jump = false;
		updateEnd();
	}

	function updateButtons() {
		for (button in buttons) {
			var isActivate = false;
			for (entity in entities) {
				if(button.getBounds().intersects(entity.getBounds())){
					isActivate = true;
					break;
				}
			}
			isActivate = isActivate || button.getBounds().intersects(entity.getBounds());
			if(isActivate){
				button.target.activated();
			}else{
				button.target.desactivated();
			}
		}
	}

	function updatePlateforms(tick:Int) {
		for (plateforme in switchingPlateformes) {
			plateforme.update();
		}
		for (plateforme in movingPlateformes) {
			var bounds = plateforme.getBounds();
			plateforme.update();
			var center = plateforme.getBounds().getCenter();
			var vector = center.sub(bounds.getCenter());
			for (entity in entities) {
				if(bounds.intersects(entity.getBounds())){
					if(entity.y < plateforme.y){
					entity.setPosition(entity.x + vector.x, entity.y +vector.y);
					}
				}
			}
			if(bounds.intersects(entity.getBounds())){
				if(entity.y < plateforme.y){
					entity.setPosition(entity.x + vector.x, entity.y +vector.y);
				}
			}
			
		}
	}

	function updateEntities(tick:Int) {
		for (entity in entities) {
			entity.playAction(tick);
			entity.update();
			resolveAction(entity);
		}
	}
	function updateEnd(){
		var bounds = end.getBounds();
		for (entity in entities) {
			if(bounds.intersects(entity.getBounds())){
				gManager.restart();
			}
		}
		if(bounds.intersects(entity.getBounds())){
			gManager.restart();
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
			resolveCollision(entity, plateforme);
		}
		for (obj in switchingPlateformes.filter(o -> o.isSolid())) {
			resolveCollision(entity, obj);
		}
		for (obj in movingPlateformes) {
			resolveCollision(entity, obj);
		}
	}

	function resolveCollision(entity:Entity, collider:Object) {
		var eBounds = entity.getBounds();
		var bounds = collider.getBounds();

		if (eBounds.intersects(bounds)) {
			var boundsInterseption = bounds.intersection(eBounds);
			if (boundsInterseption.width >= boundsInterseption.height) {
				if (entity.y < collider.y) {
					entity.touchFloor();
					entity.y -= boundsInterseption.height;
				} else {
					entity.y += boundsInterseption.height;
				}
			}
			if (boundsInterseption.width <= boundsInterseption.height) {
				if (entity.x < collider.x) {
					entity.x -= boundsInterseption.width;
				} else {
					entity.x += boundsInterseption.width;
				}
			}
		}
	}
}
