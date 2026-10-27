package;

import starling.display.Sprite;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.EnterFrameEvent;
import openfl.ui.Keyboard;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.utils.Assets;

import js.Browser;

import collectible.Collectible;
import collectible.CollectibleType;
import platform.Platform;
import movement.MovementLogic;
import movement.State;

class Game extends Sprite {
    private var movement:MovementLogic;
    private var hero:TestCharacter;

    private static inline var MAX_JUMP_TIME:Float = 0.7;
    private var spacePressed:Bool = false;
    private var spaceJustPressed:Bool = false;
    private var jumpTime:Float = 0.0;
    private var vy:Float = 0.0;
    private static inline var JUMP_STRENGTH:Float = -1050.0;
    private static inline var GRAVITY:Float = 1800.0;
    private static inline var GRAVITY_FALL:Float = 2600.0;

    private static inline var DOUBLE_JUMP_STRENGTH:Float = -650.0;
    private var canDoubleJump:Bool = false;

    private var state:State = Fall;

    private var platforms:Array<Platform> = [];


    private static inline var GRAVITY_FLOAT:Float = 200.0;
    private var canFloat:Bool = true;

    private var soundManager:SoundManager;

    private var world:Sprite;
    private var camera:Camera2D;

    private var dialogueBox:DialogueBox;
    private var isDialogueActive:Bool = false;

    private var collectibles:Array<Collectible> = [];
    private var score:Int = 0;

    private var inventory:Inventory;

    public function new() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(e:Event):Void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        world = new Sprite();
        addChild(world);
        camera = new Camera2D(world, stage.stageWidth, stage.stageHeight);

	hero = new TestCharacter();
	hero.x = stage.stageWidth / 2;
	hero.y = stage.stageHeight - 1000;
	hero.scaleX = 0.5;
	hero.scaleY = 0.5;
	movement = new MovementLogic(hero.x, hero.y, hero.width, stage.stageWidth);

	switchState(state);

	initPlatforms();
	initCollectibles();
	world.addChild(hero);
        camera.setTarget(hero);
	camera.snapToTarget();
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
	soundManager = new SoundManager();
	soundManager.initSounds();


        dialogueBox = new DialogueBox(stage.stageWidth, stage.stageHeight);
        dialogueBox.visible = false;
        dialogueBox.onComplete = () -> {
            isDialogueActive = false;
        };
        addChild(dialogueBox);
	inventory = new Inventory();
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
	    world.addChild(quad);
	}
    }

    private function onKeyDown(e:KeyboardEvent):Void {
        if (isDialogueActive) {
            dialogueBox.handleInput(e.keyCode);
            return;
        }
        if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.A) {
	    movement.leftPressed = true;
	} 
        if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.D) {
	    movement.rightPressed = true;
	}
        if (e.keyCode == Keyboard.SPACE) {
	    if (!spacePressed) {
	       spaceJustPressed = true;
	    } else {
	       spaceJustPressed = false;
	    }
	    spacePressed = true;
	}
        if (e.keyCode == Keyboard.T) {
	    dialogueTest();
	}
    }

    private function onKeyUp(e:KeyboardEvent):Void {
        if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.A) {
	    movement.leftPressed = false;
	} 
        if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.D) {
	    movement.rightPressed = false;
	}
        if (e.keyCode == Keyboard.SPACE) {
	    spacePressed = false;
            spaceJustPressed = false;
	}
    }

    private function onEnterFrame(e:EnterFrameEvent):Void {
        if (isDialogueActive) {
            dialogueBox.update(e.passedTime);
        }
        movement.updateTimers(e.passedTime);
        updateChar(e.passedTime);
        camera.update(e.passedTime);
	updateCollectibles(e.passedTime);
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

    // TODO
    private function move(dt:Float):Bool {
        var result = movement.move(dt);
	hero.x = movement.x;
	hero.scaleX = movement.scaleX;
	return result;
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
	       soundManager.play("jump");
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

	if (detectLedge()) {
	    Browser.console.log("LEDGE DETECTED");
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
	       return inventory.hasEffect(DoubleJumpAbility) && canDoubleJump;
	    case FloatState:
	       return inventory.hasEffect(FloatAbility) && movement.floatCooldown <= 0.0 && canFloat;
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
	    movement.floatCooldown = 0.2;
        }
    }

    private function detectLedge():Bool {
        var facingDir = (hero.scaleX < 0) ? -1 : 1;

        var chestX = (facingDir < 0) ? hero.x : hero.x + hero.width;
        var chestY = hero.y + (hero.height * 0.3);

        var hitPlatform:Platform = null;
        for (p in platforms) {
	    if (chestY < p.y || chestY > p.y + p.height) {
	        continue;
	    }
	    if (facingDir < 0) {
	        if (chestX >= p.x + p.width && chestX <= p.x + p.width + hero.width) {
			hitPlatform = p;
			break;
		}
	    } else {
	        if (chestX <= p.x && chestX >= p.x - hero.width) {
			hitPlatform = p;
			break;
		}
	    }
        }

        if (hitPlatform == null) return false;

        var headY = hitPlatform.y - hero.height;
        var headX = hero.x + (facingDir * 10);

        for (p in platforms) {
            if (p == hitPlatform) continue;
            if (headX + hero.width > p.x && headX < p.x + p.width &&
                headY + hero.height > p.y && headY < p.y + p.height) {
                return false;
            }
        }    


        return true;
    }


    private function dialogueTest():Void {
        isDialogueActive = true;
        dialogueBox.startDialogue([
            { speaker: "Hero", text: "Blah blah blah" },
            { speaker: "Test", text: "test test test test" },
            { speaker: "Hero", text: "test test tst test test test" }
        ]);
    }

    private function initCollectibles():Void {
        collectibles = [
            { x: 230, y: 640, width: 20, height: 20, collected: false, quad: null, type: Coin, itemId: "score" },
            { x: 610, y: 490, width: 20, height: 20, collected: false, quad: null, type: Coin, itemId: "score" },
            { x: 290, y: 340, width: 20, height: 20, collected: false, quad: null, type: Item, itemId: "speed_boots" },
            { x: 290, y: 640, width: 20, height: 20, collected: false, quad: null, type: Item, itemId: "cape" }
        ];

        for (c in collectibles) {
	    var color = (c.type == Item) ? 0x00FFFF : 0xFFD700;
            var quad = new starling.display.Quad(c.width, c.height, color);
            quad.x = c.x;
            quad.y = c.y;
            c.quad = quad;
            world.addChild(quad);
        }
    }

    private function updateCollectibles(dt:Float):Void {
        for (c in collectibles) {
            if (c.collected) continue;

            var hit = (hero.x < c.x + c.width) &&
                  (hero.x + hero.width > c.x) &&
                  (hero.y < c.y + c.height) &&
                  (hero.y + hero.height > c.y);

            if (hit) {
                c.collected = true;
                world.removeChild(c.quad);
                c.quad = null;
            
                switch (c.type) {
                    case Coin:
                        score++;
                        Browser.console.log("Collected Coin! Score: " + score);
                    case Health:
                        Browser.console.log("Restored health!");

                    case Item:
                        inventory.add(c.itemId);
			inventory.equipFromInventory(0, Boots);
			inventory.equipFromInventory(0, Armor);

		    case Resource:
                        Browser.console.log("Collected resource: " + c.itemId);
                }
            }
        }
    }
}

