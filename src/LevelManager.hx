import LdtkProject;

class LevelManager {
	var ldtkProject:LdtkProject;
	var niv:Int;

	public function new(niv:Int = 0) {
		ldtkProject = new LdtkProject();
		this.niv = niv;
	}

	public function getLevel():LdtkProject_Level {
		return ldtkProject.levels[niv];
	}

	public function nextLevel():LdtkProject_Level {
		niv++;
		if (hasNextLevel()) {
			return ldtkProject.levels[niv];
		}
		return null;
	}

	public function hasNextLevel():Bool {
		return niv + 1 < ldtkProject.levels.length;
	}

	public function restart() {
		niv = 0;
	}
}
