package;

import starling.display.Sprite;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.EnterFrameEvent;
import openfl.ui.Keyboard;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.utils.Assets;
import starling.display.Quad;

import js.Browser;

import platform.Platform;
import platform.CrumbleBehavior;
import platform.ReappearBehavior;
import platform.MoveBehavior;
import movement.MovementLogic;
import movement.State;
import dialogue.DialogueBox;
import npc.NPC;

using Intersects;

class Game extends Sprite {
    private var movement:MovementLogic;
    private var hero:TestCharacter;
    private var currentStage:GameStage;


    private var platforms:Array<Platform> = [];


    private var soundManager:SoundManager;

    private var world:Sprite;
    private var camera:Camera2D;

    private var dialogueBox:DialogueBox;
    private var isDialogueActive:Bool = false;

    private var score:Int = 0;
    private var chars:Array<NPC> = [];

    private var inventory:Inventory;

    private var hud:HUDLayer;

    public function new() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(e:Event):Void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        world = new Sprite();
        addChild(world);

        currentStage = new GameStage();
        world.addChild(currentStage);

        camera = new Camera2D(world, stage.stageWidth, stage.stageHeight);

	hero = new TestCharacter();
	hero.x = currentStage.heroSpawnX;
	hero.y = currentStage.heroSpawnY;
	hero.scaleX = 0.5;
	hero.scaleY = 0.5;
	movement = new MovementLogic(hero.x, hero.y, hero.width, hero.height, currentStage.stageWidth, currentStage.stageHeight);
	movement.onStartFall = hero.startFall;
	movement.onStartJump = hero.startJump;
	movement.onStartDoubleJump = hero.startDoubleJump;
	movement.onStartFloat = hero.startFloat;
	movement.onEndRun = hero.endRun;
	movement.onStartRun = hero.startRun;
	movement.isUnlocked = this.stateIsUnlocked;
	movement.getLandedPlatform = currentStage.getLandedPlatform;
	movement.isOnFloor = currentStage.isOnFloor;

	movement.switchState(movement.state);

	initNPCs();
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

        hud = new HUDLayer(stage.stageWidth);
        addChild(hud);
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
        if (e.keyCode == Keyboard.ENTER) {
	    interact();
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
	currentStage.update(e.passedTime);
        movement.updateTimers(e.passedTime);
        updateChar(e.passedTime);
        for (npc in chars) npc.update(e.passedTime);
        camera.update(e.passedTime);
	updateCollectibles(e.passedTime);
    }

    private function updateChar(dt:Float):Void {
	movement.update(dt);
	updateHeroSprite();
    }

    private function updateHeroSprite():Void {
        hero.x = movement.x;
	hero.y = movement.y;
	hero.scaleX = movement.scaleX;
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
        for (p in currentStage.platforms) {
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

        for (p in currentStage.platforms) {
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
            { speaker: "Test", text: "test test test test", portraitId: "test" },
            { speaker: null, text: "narrator test", portraitId: "test" },
            { speaker: "Hero", text: "test?", choices: [
	        { text: "1", nextIndex: 4},
	        { text: "2", nextIndex: 5},
	    ]},
            { speaker: "Hero", text: "Test 1", nextIndex: 10000 },
            { speaker: "Hero", text: "Test 2" },
        ]);
    }

    private function initNPCs():Void {
	    var color = 0xFFD700;
            var npc = new NPC(900, 780, 30, 50, color);
            world.addChild(npc);
            npc.onInteraction = dialogueTest;
	    chars.push(npc);
    }

    private function interact():Void {
        for (c in chars) {
            if (c.onInteraction == null) continue;

            var hit = hero.intersects(c);
            if (hit) {
	        c.onInteraction();
            }
        }
    }


    private function updateCollectibles(dt:Float):Void {
        for (c in currentStage.collectibles) {
            if (c.collected) continue;

            var hit = hero.intersects(c.quad);
            if (hit) {
                c.collected = true;
                currentStage.removeChild(c.quad);
                c.quad = null;
            
                switch (c.type) {
                    case Coin:
                        score++;
			hud.updateScore(score);
                        Browser.console.log("Collected Coin! Score: " + score);
                    case Health:
                        Browser.console.log("Restored health!");

                    case Item:
                        inventory.add(c.itemId);

		    case Resource:
                        Browser.console.log("Collected resource: " + c.itemId);
                }
            }
        }
    }
}

