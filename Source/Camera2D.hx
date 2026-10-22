package;

import starling.display.DisplayObject;
import starling.display.Sprite;

class Camera2D {
    private var world:Sprite;
    private var target:DisplayObject;

    public var x(default, null):Float = 0.0;
    public var y(default, null):Float = 0.0;

    public var lerpSpeed:Float = 6.0;
    public var offsetX:Float = 0.0;
    public var offsetY:Float = 0.0;

    private var screenWidth:Float;
    private var screenHeight:Float;

    public function new(world:Sprite, screenWidth:Float, screenHeight:Float) { this.world = world;
        this.screenWidth = screenWidth;
        this.screenHeight = screenHeight;
    }

    public function setTarget(target:DisplayObject):Void {
        this.target = target;
    }

    public function snapToTarget():Void {
        if (target == null) return;
        
        x = -target.x + (screenWidth / 2) - (target.width / 2) + offsetX;
        y = -target.y + (screenHeight / 2) - (target.height / 2) + offsetY;
        
        world.x = x;
        world.y = y;
    }

    public function update(dt:Float):Void {
        if (target == null) return;

        var targetX = -target.x + (screenWidth / 2) - (target.width / 2) + offsetX;
        var targetY = -target.y + (screenHeight / 2) - (target.height / 2) + offsetY;

        x += (targetX - x) * lerpSpeed * dt;
        y += (targetY - y) * lerpSpeed * dt;

        world.x = x;
        world.y = y;
    }
}
