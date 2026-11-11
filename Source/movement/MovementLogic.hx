package movement;

import platform.Platform;


class MovementLogic {
    public var floatCooldown:Float = 0.0;

    public var x:Float;
    public var y:Float;
    public var width:Float;
    public var height:Float;
    public var scaleX:Float = 0.5;
    public var stageWidth:Float;
    public var stageHeight:Float;

    private static inline var ACCELERATION:Float = 4500.0;
    private static inline var MAX_SPEED:Float = 500.0;
    private static inline var FRICTION:Float = 14.0;
    private var vx:Float = 0.0;

    public var leftPressed:Bool = false;
    public var rightPressed:Bool = false;
    public var spacePressed:Bool = false;
    public var spaceJustPressed:Bool = false;

    public var state:State = Fall;

    private static inline var MAX_JUMP_TIME:Float = 0.7;
    public var jumpTime:Float = 0.0;
    public var vy:Float = 0.0;
    public static inline var JUMP_STRENGTH:Float = -1050.0;
    public static inline var GRAVITY:Float = 1800.0;
    public static inline var GRAVITY_FALL:Float = 2600.0;

    public var canDoubleJump:Bool = false;
    private static inline var DOUBLE_JUMP_STRENGTH:Float = -650.0;
    public static inline var GRAVITY_DOUBLE_JUMP:Float = 1800.0;

    private static inline var GRAVITY_FLOAT:Float = 200.0;
    public var canFloat:Bool = true;


    public var onStartFall: Void -> Void;
    public var onStartJump: Void -> Void;
    public var onStartDoubleJump: Void -> Void;
    public var onStartFloat: Void -> Void;
    public var onEndRun: Void -> Void;
    public var onStartRun: Void -> Void;
    public var isUnlocked: State -> Bool;
    public var getLandedPlatform: (x:Float, y:Float, width:Float, height:Float, nextX: Float, nextY: Float) -> Platform;
    public var soundManager: SoundManager;
    public var isOnFloor: (x:Float, y:Float, width:Float, height:Float) -> Bool;

    public var platform:Platform;

    public function new(x:Float, y:Float, width:Float, height:Float, stageWidth:Float, stageHeight:Float) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.stageWidth = stageWidth;
        this.stageHeight = stageHeight;

    }

    private function updateTimers(dt:Float):Void {
        if (floatCooldown > 0.0) {
	    floatCooldown -= dt;
	}
    }


    public function preMove(dt:Float):Void {
        x += platform.dx;
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


    public function jump(dt:Float):Void {
        jumpTime += dt;
        if (!spacePressed) {
            if (vy < 0) {
                vy *= 0.3; 
            }
	    switchState(Fall);
	    return;
	}

        var currentGravity = GRAVITY;
        if (Math.abs(vy) < 150.0) {
            currentGravity *= 0.3;
        }

	vy += GRAVITY * dt;
	y += vy * dt;

	if (vy >= 0) {
	    switchState(Fall);
	}
    }


    public function switchState(newState:State):Void {
        if (!isUnlocked(newState)) {
	    return;
	}
        state = newState;

        switch(newState) {
	    case Fall:
	       onStartFall();
	    case Floor:
	       onEndRun();
	    case Jump:
	       soundManager.play("jump");
	       canDoubleJump = true;
	       jumpTime = 0.0;
	       vy = JUMP_STRENGTH;
	       onStartJump();
	    case DoubleJump:
	       vy = DOUBLE_JUMP_STRENGTH;
	       canDoubleJump = false;
	       onStartDoubleJump();
	    case FloatState:
	       vy = 0.0;
	       onStartFloat();
	}
    }

    public function fall(dt:Float):Void {
	vy += GRAVITY_FALL * dt;
	var nextY = y + vy * dt;

	var landedPlatform:Platform = getLandedPlatform(
	    x, y, width, height, x, nextY
        );

        if (landedPlatform != null) {
	    y = landedPlatform.y - height;
	    platform = landedPlatform;
	    switchState(Floor);
	    vy = 0;
	    return;
	}
        y = nextY;

        if (y > stageHeight - height) {
            y = stageHeight - height;
            switchState(Floor);
            vy = 0;
        }

        if (spaceJustPressed) {
            switchState(DoubleJump);
	    if (state == Fall) {
	        switchState(FloatState);
	    }
        } 
    }

    public function doubleJump(dt:Float):Void {
        var currentGravity = GRAVITY_DOUBLE_JUMP;
        if (Math.abs(vy) < 150.0) {
            currentGravity *= 0.3;
        }

	vy += currentGravity * dt;
	y += vy * dt;

	if (vy >= 0) {
	    switchState(Fall);
	}
    }



    public function float(dt:Float):Void {
	vy += GRAVITY_FLOAT * dt;
	var nextY = y + vy * dt;

	var landedPlatform:Platform = getLandedPlatform(
	    x, y, width, height, x, nextY
        );

        if (landedPlatform != null) {
	    y = landedPlatform.y - height;
	    platform = landedPlatform;
	    switchState(Floor);
	    vy = 0;
	    return;
	}
        y = nextY;

        if (y > stageHeight - height) {
            y = stageHeight - height;
            switchState(Floor);
            vy = 0;
        }

        if (!spacePressed) {
            switchState(Fall);
	    floatCooldown = 0.2;
        }
    }


    public function update(dt:Float):Void {
        updateTimers(dt);
        switch(state) {
	    case Fall:
	       fall(dt);
	       move(dt);
	    case Floor:
	       preMove(dt);
	       if (move(dt)) {
	           onStartRun();
	       } else {
	           onEndRun();
	       }
	       if (!isOnFloor(x, y, width, height)) {
		       switchState(Fall);
	       }
	       if (spacePressed) {
	          switchState(Jump);
	       }
	    case Jump:
	       jump(dt);
	       move(dt);
	    case DoubleJump:
	       doubleJump(dt);
	       move(dt);
	    case FloatState:
	       float(dt);
	       move(dt);
	}
    }
}
