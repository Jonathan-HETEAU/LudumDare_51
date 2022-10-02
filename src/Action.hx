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