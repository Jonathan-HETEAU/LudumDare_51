class Main extends hxd.App implements GameManager {
	var levelManager:LevelManager;
	var game:Game;

	override function init() {
		hxd.Window.getInstance().title = "TimeStick";
		levelManager = new LevelManager(0);
		game = null;
		menu();
	}

	override function update(deltat:Float) {
		super.update(deltat);
		if(game != null){
		game.update(deltat);
		}
	}

	public function quit():Void {}

	public function nextLevel():Void {
		if(levelManager.hasNextLevel()){
			levelManager.nextLevel();
			play();
		}else{
			menu();
		}
	}
	public function play():Void{
		game = new Game(levelManager.getLevel(),this);
		setScene2D(game);
	}

	public function restart():Void {
		levelManager.restart();
		play();
	}

	public function menu():Void {
		game = null;
		setScene(new Menu(this));
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main();
	}
}
