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
    private var jumpTime:Float = 0.0;

    private var state:State = Fall;


    public function new() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(e:Event):Void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

	hero = new TestCharacter();
	hero.x = stage.stageWidth / 2;
	hero.y = stage.stageHeight - 500;
	hero.scaleX = 0.5;
	hero.scaleY = 0.5;

	switchState(state);

	addChild(hero);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onKeyDown(e:KeyboardEvent):Void {
        if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.A) {
	    leftPressed = true;
	} 
        if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.D) {
	    rightPressed = true;
	}
        if (e.keyCode == Keyboard.SPACE) {
	    spacePressed = true;
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
	}
    }

    private function onEnterFrame(e:EnterFrameEvent):Void {
        updateChar(e.passedTime);
    }

    private function updateChar(dt:Float):Void {
        switch(state) {
	    case Fall:
	       fall(dt);
	    case Floor:
	       move(dt);
	       if (spacePressed) {
	          switchState(Jump);
	       }
	    case Jump:
	       jump(dt);
	}
    }


    private function switchState(newState:State):Void {
        state = newState;

        switch(newState) {
	    case Fall:
	       hero.startFall();
	    case Floor:
	       hero.endRun();
	    case Jump:
	       jumpTime = 0.0;
	       hero.startJump();
	}
    }


    private function fall(dt:Float):Void {
        if (isOnFloor()) {
	    switchState(Floor);
	    return;
	}
	hero.y += 10;
	if (hero.y > 900) hero.y = 900;
    }

    private function jump(dt:Float):Void {
        jumpTime += dt;
        if (!spacePressed || jumpTime >= MAX_JUMP_TIME) {
	    switchState(Fall);
	}
    }

    private function move(dt:Float):Void {
        var moveDir:Float = 0.0;
        if (leftPressed) moveDir -= 1.0;
        if (rightPressed) moveDir += 1.0;

        if (moveDir != 0.0) {
            vx += moveDir * ACCELERATION * dt;
            hero.startRun();
        } else {
            vx -= vx * FRICTION * dt;
            hero.endRun();
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

	if (!isOnFloor()) {
	    switchState(Fall);
	}
    }

   public function isOnFloor():Bool {
      return hero.y >= 900;
   }
}

