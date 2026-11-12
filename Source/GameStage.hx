package;

import starling.display.Sprite;
import platform.Platform;
import platform.CrumbleBehavior;
import platform.ReappearBehavior;
import platform.MoveBehavior;
import npc.NPC;
import movement.MovementLogic;
import movement.State;
import dialogue.DialogueLine;

import collectible.Collectible;
import collectible.CollectibleType;
import js.Browser;
import starling.events.KeyboardEvent;
import openfl.ui.Keyboard;

using Intersects;

class GameStage extends Sprite {
    private var platforms:Array<Platform> = [];
    private var collectibles:Array<Collectible> = [];
    private var chars:Array<NPC> = [];

    public var makeDialogue: (lines:Array<DialogueLine>) -> (() -> Void);

    private var hero:TestCharacter;
    private var inventory:Inventory;
    public var movement:MovementLogic;
    public var score:Int = 0;

    public var stageWidth:Float;
    public var stageHeight:Float;
    public var heroSpawnX:Float;
    public var heroSpawnY:Float;

    public function new(makeDialogue: (lines:Array<DialogueLine>) -> (() -> Void)) {
        super();
	stageWidth = 2000;
	stageHeight = 1000;
	heroSpawnX = stageWidth / 2;
        heroSpawnY = stageHeight - 300;
	this.makeDialogue = makeDialogue;
        initPlatforms();
	initCollectibles();
	initNPCs();
    }

    public function addHero(hero:TestCharacter, inventory:Inventory):Void {
	hero.x = heroSpawnX;
	hero.y = heroSpawnY;
	hero.scaleX = 0.5;
	hero.scaleY = 0.5;
	this.hero = hero;
	addChild(hero);
	this.inventory = inventory;

	movement = new MovementLogic(hero.x, hero.y, hero.width, hero.height, stageWidth, stageHeight);
	movement.onStartFall = hero.startFall;
	movement.onStartJump = hero.startJump;
	movement.onStartDoubleJump = hero.startDoubleJump;
	movement.onStartFloat = hero.startFloat;
	movement.onEndRun = hero.endRun;
	movement.onStartRun = hero.startRun;
	movement.isUnlocked = this.stateIsUnlocked;
	movement.getLandedPlatform = getLandedPlatform;
	movement.isOnFloor = isOnFloor;

	movement.switchState(movement.state);
    }

    private function initPlatforms():Void {
        platforms = [
            new Platform(100, 700, 300, 20),
            new Platform(500, 550, 250, 20),
            new Platform(200, 400, 200, 20),
            new Platform(0, stageHeight - 50, stageWidth, 50)
        ];
        var crumblingPlatform = new Platform(900, 400, 250, 20)
            .addBehavior(new CrumbleBehavior(1.5))
            .addBehavior(new ReappearBehavior(4.0));
        platforms.push(crumblingPlatform);

        var movingPlatform = new Platform(1200, 400, 50, 20)
            .addBehavior(new MoveBehavior(1200, 1400, 2.0));
        platforms.push(movingPlatform);
        for (p in platforms) {
            addChild(p);
        }
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
            addChild(quad);
        }
    }

    private function initNPCs():Void {
	    var color = 0xFFD700;
            var npc = new NPC(900, 780, 30, 50, color);
            addChild(npc);
            npc.onInteraction = makeDialogue([
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
	    chars.push(npc);
    }

    public function update(dt:Float):Void {
        for (p in platforms) p.update(dt);
        for (npc in chars) npc.update(dt);
	updateCollectibles(dt);
        updateChar(dt);
    }

    public function getLandedPlatform(x:Float, y:Float, width:Float, height:Float, nextX: Float, nextY: Float):Platform {
	for (p in platforms) {
	    if (p.landedOn(x, y, width, height, nextX, nextY)) {
	        p.notifyLandedOn();
	        return p;
            }
	}
	return null;
    }

    public function isOnFloor(x:Float, y:Float, width:Float, height:Float):Bool {
        for (p in platforms) {
	    if (p.isOn(x, y, width, height)) {
                return true;
            }
        }
        return false;
    }

    public function interact():Void {
        for (c in chars) {
            if (c.onInteraction == null) continue;

            var hit = hero.intersects(c);
            if (hit) {
	        c.onInteraction();
            }
        }
    }


    private function updateCollectibles(dt:Float):Void {
        for (c in collectibles) {
            if (c.collected) continue;

            var hit = hero.intersects(c.quad);
            if (hit) {
                c.collected = true;
                removeChild(c.quad);
                c.quad = null;
            
                switch (c.type) {
                    case Coin:
                        score++;
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


    public function onKeyDown(e:KeyboardEvent):Void {
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

    public function onKeyUp(e:KeyboardEvent):Void {
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


    private function updateChar(dt:Float):Void {
	movement.update(dt);
	updateHeroSprite();
    }

    private function updateHeroSprite():Void {
        hero.x = movement.x;
	hero.y = movement.y;
	hero.scaleX = movement.scaleX;
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
}
