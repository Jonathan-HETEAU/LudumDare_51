import LdtkProject;

class LevelManager {
	var ldtkProject:LdtkProject;

	public function new() {
		ldtkProject = new LdtkProject();
	}

	public function getLevel():Layer_Map {
		var map = ldtkProject.all_levels.Level_0.l_Map;
		return map;
	}
}
