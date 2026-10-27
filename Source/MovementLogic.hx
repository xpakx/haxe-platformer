package;


class MovementLogic {
    public var floatCooldown:Float = 0.0;


    public function new() {
    }

    public function updateTimers(dt:Float):Void {
        if (floatCooldown > 0.0) {
	    floatCooldown -= dt;
	}
    }
}
