class Main extends hxd.App {
	var gManager:LevelManager;
	var game:Game;

	override function init() {
		hxd.Window.getInstance().title = "TimeStick";
		gManager = new LevelManager();
		game = new Game(gManager.getLevel());
		setScene2D(game);
	}

	override function update(deltat:Float) {
		super.update(deltat);
		game.update(deltat);
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main();
	}
}
