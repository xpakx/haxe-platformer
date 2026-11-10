package;

import starling.display.Sprite;
import platform.Platform;
import platform.CrumbleBehavior;
import platform.ReappearBehavior;
import platform.MoveBehavior;

import collectible.Collectible;
import collectible.CollectibleType;
import js.Browser;

class GameStage extends Sprite {
    public var platforms:Array<Platform> = [];
    public var collectibles:Array<Collectible> = [];

    public var stageWidth:Float;
    public var stageHeight:Float;
    public var heroSpawnX:Float;
    public var heroSpawnY:Float;

    public function new() {
        super();
	stageWidth = 2000;
	stageHeight = 1000;
	heroSpawnX = stageWidth / 2;
        heroSpawnY = stageHeight - 300;
        initPlatforms();
	initCollectibles();
    }

    public function addHero(hero:TestCharacter):Void {
	hero.x = heroSpawnX;
	hero.y = heroSpawnY;
	hero.scaleX = 0.5;
	hero.scaleY = 0.5;
	addChild(hero);
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

    public function update(passedTime:Float):Void {
        for (p in platforms) p.update(passedTime);
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
}
