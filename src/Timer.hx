class Timer {
	inline static var delay:Float = 0.2;
	inline static var tickPerSec:Float = 50;
	

	var time:Float;
	var tick:Int;

	public function new() {
		time = 0.;
		tick = 0;
	}

	public function add(deltat:Float) {
		time += deltat;
		tick = Std.int(Math.abs(time * tickPerSec));
	}

	
	public function getTick() {
		return tick;
	}

	public function restart(){
		time = 0;
		tick = 0;
	}

	public function toString():String {
		return ""+Math.round(time);
	}
}
