package;

import starling.display.Sprite;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.EnterFrameEvent;
import openfl.ui.Keyboard;

import js.Browser;

class Game extends Sprite {
    private var hero:SpineCharacter;

    public function new() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(e:Event):Void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

	hero = new SpineCharacter();
	hero.x = stage.stageWidth / 2;
	hero.y = stage.stageHeight - 100;
	hero.scaleX = 0.5;
	hero.scaleY = 0.5;


	addChild(hero);
    }

}

