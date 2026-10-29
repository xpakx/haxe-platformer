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


    private var platforms:Array<Platform> = [];



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
	movement = new MovementLogic(hero.x, hero.y, hero.width, hero.height, stage.stageWidth);
	movement.onStartFall = hero.startFall;
	movement.onStartJump = hero.startJump;
	movement.onStartDoubleJump = hero.startDoubleJump;
	movement.onStartFloat = hero.startFloat;
	movement.onEndRun = hero.startRun;
	movement.isUnlocked = this.stateIsUnlocked;
	movement.getLandedPlatform = this.getLandedPlatform;

	movement.switchState(movement.state);

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
	movement.soundManager = soundManager;


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
	    if (!movement.spacePressed) {
	       movement.spaceJustPressed = true;
	    } else {
	       movement.spaceJustPressed = false;
	    }
	    movement.spacePressed = true;
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
	    movement.spacePressed = false;
            movement.spaceJustPressed = false;
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
        movement.y = hero.y;
        switch(movement.state) {
	    case Fall:
	       movement.fall(dt);
	       move(dt);
	    case Floor:
	       if (move(dt)) {
	           hero.startRun();
	       } else {
	           hero.endRun();
	       }
	       if (!isOnFloor()) {
		       movement.switchState(Fall);
	       }
	       if (movement.spacePressed) {
	          movement.switchState(Jump);
	       }
	    case Jump:
	       jump(dt);
	    case DoubleJump:
	       movement.doubleJump(dt);
	       move(dt);
	    case FloatState:
	       movement.float(dt);
	       move(dt);
	}
    }

    // TODO
    private function move(dt:Float):Bool {
        var result = movement.move(dt);
	updateHeroSprite();
	return result;
    }

    // TODO
    private function jump(dt:Float):Void {
        movement.jump(dt);
	move(dt);
	updateHeroSprite();
    }

    private function updateHeroSprite():Void {
        hero.x = movement.x;
	hero.y = movement.y;
	hero.scaleX = movement.scaleX;
    }


    private function getLandedPlatform(x:Float, y:Float, width:Float, height:Float, nextX: Float, nextY: Float):Platform {
	for (p in platforms) {
	    var hitX = (x + width > p.x) && (x < p.x + p.width);
	    var floor = p.y - height;
	    var crossedTop = (y <= floor) && (nextY >= floor);

	    if (hitX && crossedTop) {
	        return p;
            }
	}
	return null;
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
	       return inventory.hasEffect(DoubleJumpAbility) && movement.canDoubleJump;
	    case FloatState:
	       return inventory.hasEffect(FloatAbility) && movement.floatCooldown <= 0.0 && movement.canFloat;
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

