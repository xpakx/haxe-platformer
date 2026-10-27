package;


class MovementLogic {
    public var floatCooldown:Float = 0.0;

    public var x:Float;
    public var y:Float;
    public var width:Float;
    public var scaleX:Float = 0.5;
    public var stageWidth:Float;

    private static inline var ACCELERATION:Float = 4500.0;
    private static inline var MAX_SPEED:Float = 500.0;
    private static inline var FRICTION:Float = 14.0;
    private var vx:Float = 0.0;

    public var leftPressed:Bool = false;
    public var rightPressed:Bool = false;


    public function new(x:Float, y:Float, width:Float, stageWidth:Float) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.stageWidth = stageWidth;

    }

    public function updateTimers(dt:Float):Void {
        if (floatCooldown > 0.0) {
	    floatCooldown -= dt;
	}
    }


    public function move(dt:Float):Bool {
        var moveDir:Float = 0.0;
	var moved:Bool = false;
        if (leftPressed) moveDir -= 1.0;
        if (rightPressed) moveDir += 1.0;

        if (moveDir != 0.0) {
            vx += moveDir * ACCELERATION * dt;
	    moved = true;
        } else {
            vx -= vx * FRICTION * dt;
        }

        if (vx > MAX_SPEED) vx = MAX_SPEED;
        if (vx < -MAX_SPEED) vx = -MAX_SPEED;
	if (vx < 0) {
		scaleX = -0.5; 
	} else {
		scaleX = 0.5; 
	}

        x += vx * dt;

        if (x < 0) {
            x = 0;
	    vx = 0;
        } else if (x + width > stageWidth) {
            x = stageWidth - width;
	    vx = 0;
        }

	return moved;
    }
}
