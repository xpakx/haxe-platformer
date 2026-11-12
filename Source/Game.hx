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
import dialogue.DialogueBox;
import npc.NPC;

using Intersects;

class Game extends Sprite {
    private var hero:TestCharacter;
    private var currentStage:GameStage;

    private var soundManager:SoundManager;

    private var world:Sprite;
    private var camera:Camera2D;

    private var dialogueBox:DialogueBox;
    private var isDialogueActive:Bool = false;


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

	inventory = new Inventory();
	hero = new TestCharacter();
	currentStage.addHero(hero, inventory);

	initNPCs();
        camera.setTarget(hero);
	camera.snapToTarget();
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
	soundManager = new SoundManager();
	soundManager.initSounds();
	currentStage.movement.soundManager = soundManager;


        dialogueBox = new DialogueBox(stage.stageWidth, stage.stageHeight);
        dialogueBox.visible = false;
        dialogueBox.onComplete = () -> {
            isDialogueActive = false;
        };
        addChild(dialogueBox);

        hud = new HUDLayer(stage.stageWidth);
        addChild(hud);
    }

    private function onKeyDown(e:KeyboardEvent):Void {
        if (isDialogueActive) {
            dialogueBox.handleInput(e.keyCode);
            return;
        }
	currentStage.onKeyDown(e);
    }

    private function onKeyUp(e:KeyboardEvent):Void {
	currentStage.onKeyUp(e);
    }

    private function onEnterFrame(e:EnterFrameEvent):Void {
        if (isDialogueActive) {
            dialogueBox.update(e.passedTime);
        }
	currentStage.update(e.passedTime);
        camera.update(e.passedTime);
	hud.updateScore(currentStage.score);
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
	    currentStage.chars.push(npc);
    }
}

