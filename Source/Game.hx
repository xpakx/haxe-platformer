package;

import starling.display.Sprite;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.EnterFrameEvent;
import openfl.ui.Keyboard;

import js.Browser;


enum State {
   Fall;
   Floor;
   Jump;
   DoubleJump;
   FloatState;
}

typedef Platform = {
    var x:Float;
    var y:Float;
    var width:Float;
    var height:Float;
}

class Game extends Sprite {
    private var hero:TestCharacter;
    private var leftPressed:Bool = false;
    private var rightPressed:Bool = false;
    private var vx:Float = 0.0;
    private static inline var ACCELERATION:Float = 4500.0;
    private static inline var MAX_SPEED:Float = 500.0;
    private static inline var FRICTION:Float = 14.0;


    private static inline var MAX_JUMP_TIME:Float = 0.7;
    private var spacePressed:Bool = false;
    private var spaceJustPressed:Bool = false;
    private var jumpTime:Float = 0.0;
    private var vy:Float = 0.0;
    private static inline var JUMP_STRENGTH:Float = -1050.0;
    private static inline var GRAVITY:Float = 1800.0;
    private static inline var GRAVITY_FALL:Float = 2600.0;

    private static inline var DOUBLE_JUMP_STRENGTH:Float = -650.0;
    private var doubleJumpUnlocked:Bool = false;
    private var canDoubleJump:Bool = false;

    private var state:State = Fall;

    private var platforms:Array<Platform> = [];


    private static inline var GRAVITY_FLOAT:Float = 200.0;
    private var canFloat:Bool = true;


    public function new() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(e:Event):Void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

	hero = new TestCharacter();
	hero.x = stage.stageWidth / 2;
	hero.y = stage.stageHeight - 1000;
	hero.scaleX = 0.5;
	hero.scaleY = 0.5;

	switchState(state);

	initPlatforms();
	addChild(hero);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }


    private function initPlatforms():Void {
        platforms = [
        { x: 100, y: 700, width: 300, height: 20 },
        { x: 500, y: 550, width: 250, height: 20 },
        { x: 200, y: 400, width: 200, height: 20 },
        { x: 0, y: 850, width: stage.stageWidth, height: 50 }
        ];

	for (p in platforms) {
	    var quad = new starling.display.Quad(p.width, p.height, 0x555555);
	    quad.x = p.x;
	    quad.y = p.y;
	    addChild(quad);
	}
    }

    private function onKeyDown(e:KeyboardEvent):Void {
        if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.A) {
	    leftPressed = true;
	} 
        if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.D) {
	    rightPressed = true;
	}
        if (e.keyCode == Keyboard.SPACE) {
	    if (!spacePressed) {
	       spaceJustPressed = true;
	    } else {
	       spaceJustPressed = false;
	    }
	    spacePressed = true;
	}
        if (e.keyCode == Keyboard.J) {
	    doubleJumpUnlocked = !doubleJumpUnlocked;
	}
    }

    private function onKeyUp(e:KeyboardEvent):Void {
        if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.A) {
	    leftPressed = false;
	} 
        if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.D) {
	    rightPressed = false;
	}
        if (e.keyCode == Keyboard.SPACE) {
	    spacePressed = false;
            spaceJustPressed = false;
	}
    }

    private function onEnterFrame(e:EnterFrameEvent):Void {
        updateChar(e.passedTime);
    }

    private function updateChar(dt:Float):Void {
        switch(state) {
	    case Fall:
	       fall(dt);
	       move(dt);
	    case Floor:
	       if (move(dt)) {
	           hero.startRun();
	       } else {
	           hero.endRun();
	       }
	       if (!isOnFloor()) {
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


    private function switchState(newState:State):Void {
        if (!stateIsUnlocked(newState)) {
	    return;
	}
        state = newState;

        switch(newState) {
	    case Fall:
	       hero.startFall();
	    case Floor:
	       hero.endRun();
	    case Jump:
	       canDoubleJump = true;
	       jumpTime = 0.0;
	       vy = JUMP_STRENGTH;
	       hero.startJump();
	    case DoubleJump:
	       vy = DOUBLE_JUMP_STRENGTH;
	       canDoubleJump = false;
	       hero.startDoubleJump();
	    case FloatState:
	       vy = 0.0;
	       hero.startFloat();
	}
    }


    private function fall(dt:Float):Void {
	vy += GRAVITY_FALL * dt;
	var nextY = hero.y + vy * dt;

	var landedPlatform:Platform = null;
	for (p in platforms) {
	    var hitX = (hero.x + hero.width > p.x) && (hero.x < p.x + p.width);
	    var floor = p.y - hero.height;
	    var crossedTop = (hero.y <= floor) && (nextY >= floor);

	    if (hitX && crossedTop) {
	        landedPlatform = p;
	        break;
            }
	}

        if (landedPlatform != null) {
	    hero.y = landedPlatform.y - hero.height;
	    switchState(Floor);
	    vy = 0;
	    return;
	}
        hero.y = nextY;

        if (hero.y > 900) {
            hero.y = 900;
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

    private function jump(dt:Float):Void {
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
	hero.y += vy * dt;

	if (vy >= 0) {
	    switchState(Fall);
	}
    }

    private function doubleJump(dt:Float):Void {
        var currentGravity = GRAVITY;
        if (Math.abs(vy) < 150.0) {
            currentGravity *= 0.3;
        }

	vy += GRAVITY * dt;
	hero.y += vy * dt;

	if (vy >= 0) {
	    switchState(Fall);
	}
    }

    private function move(dt:Float):Bool {
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
		hero.scaleX = -0.5; 
	} else {
		hero.scaleX = 0.5; 
	}

        hero.x += vx * dt;

        if (hero.x < 0) {
            hero.x = 0;
	    vx = 0;
        } else if (hero.x + hero.width > stage.stageWidth) {
            hero.x = stage.stageWidth - hero.width;
	    vx = 0;
        }

	return moved;
    }

    public function isOnFloor():Bool {
        for (p in platforms) {
            var hitX = (hero.x + hero.width > p.x) && (hero.x < p.x + p.width);

	    var floor = p.y - hero.height;

            var hitY = (hero.y >= floor) && (hero.y <= floor + 15);

            if (hitX && hitY) {
                return true;
            }
        }
        return false;
    }


    private function stateIsUnlocked(newState:State):Bool {
        switch(newState) {
	    case Fall:
	       return true;
	    case Floor:
	       return true;
	    case Jump:
	       return true;
	    case DoubleJump:
	       return doubleJumpUnlocked && canDoubleJump;
	    case FloatState:
	       return canFloat;
	}
    }

    private function float(dt:Float):Void {
	vy += GRAVITY_FLOAT * dt;
	var nextY = hero.y + vy * dt;

	var landedPlatform:Platform = null;
	for (p in platforms) {
	    var hitX = (hero.x + hero.width > p.x) && (hero.x < p.x + p.width);
	    var floor = p.y - hero.height;
	    var crossedTop = (hero.y <= floor) && (nextY >= floor);

	    if (hitX && crossedTop) {
	        landedPlatform = p;
	        break;
            }
	}

        if (landedPlatform != null) {
	    hero.y = landedPlatform.y - hero.height;
	    switchState(Floor);
	    vy = 0;
	    return;
	}
        hero.y = nextY;

        if (hero.y > 900) {
            hero.y = 900;
            switchState(Floor);
            vy = 0;
        }

        if (!spacePressed) {
            switchState(Fall);
        }
    }
}

