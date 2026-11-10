package;

import starling.display.Sprite;
import platform.Platform;
import platform.CrumbleBehavior;
import platform.ReappearBehavior;
import platform.MoveBehavior;

class GameStage extends Sprite {
    public var platforms:Array<Platform> = [];
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
