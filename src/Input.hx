import hxd.Event;

class Input {
	public var action:Action = new Action();
	public var jump:Bool = false;
	public var play:Bool = false;

	public function new() {}

	

	public function onEvent(event:Event) {
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
						jump = true;
					case _:
				}
			case _:
		}
	}
}
