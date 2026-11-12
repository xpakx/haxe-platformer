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
import dialogue.DialogueLine;

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

    // TODO: multiple stages (codegen?)
    private function loadStage() {
        currentStage = new GameStage(this);
        world.addChild(currentStage);
	currentStage.addHero(hero, inventory);
	currentStage.initSound(soundManager);

        camera.setTarget(hero);
	camera.snapToTarget();
    }

    private function onAddedToStage(e:Event):Void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        world = new Sprite();
        addChild(world);

        camera = new Camera2D(world, stage.stageWidth, stage.stageHeight);

	inventory = new Inventory();
	hero = new TestCharacter();

	soundManager = new SoundManager();
	soundManager.initSounds();

        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);

        dialogueBox = new DialogueBox(stage.stageWidth, stage.stageHeight);
        dialogueBox.visible = false;
        dialogueBox.onComplete = () -> {
            isDialogueActive = false;
        };
        addChild(dialogueBox);

        hud = new HUDLayer(stage.stageWidth);
        addChild(hud);

	loadStage();
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

    public function makeDialogue(lines:Array<DialogueLine>):() -> Void {
        return () -> {
            isDialogueActive = true;
            dialogueBox.startDialogue(lines);
        };
    }
}

