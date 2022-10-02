class Main extends hxd.App implements GameManager {
	var levelManager:LevelManager;
	var game:Game;

	override function init() {
		hxd.Window.getInstance().title = "TimeStick";
		levelManager = new LevelManager();
		
		game = new Game(levelManager.getLevel(),this);
		setScene2D(game);
	}

	override function update(deltat:Float) {
		super.update(deltat);
		game.update(deltat);
	}

	public function quit():Void {}

	public function nextLevel():Void {
		if(levelManager.hasNextLevel()){

		}
	}

	public function restart():Void {
		game = new Game(levelManager.getLevel(),this);
		setScene2D(game);
	}

	public function menu():Void {}

	static function main() {
		hxd.Res.initEmbed();
		new Main();
	}
}
