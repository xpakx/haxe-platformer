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

    public var deadzoneWidth:Float = 400.0;
    public var deadzoneHeight:Float = 240.0;

    private var focusX:Float = 0.0;
    private var focusY:Float = 0.0;

    public function new(world:Sprite, screenWidth:Float, screenHeight:Float) { this.world = world;
        this.screenWidth = screenWidth;
        this.screenHeight = screenHeight;
    }

    public function setTarget(target:DisplayObject):Void {
        this.target = target;
    }

    public function snapToTarget():Void {
        if (target == null) return;
        focusX = target.x + (target.width / 2);
        focusY = target.y + (target.height / 2);
        updateWorldPosition();
    }

    public function update(dt:Float):Void {
        if (target == null) return;

        var targetCenterX = target.x + (target.width / 2);
        var targetCenterY = target.y + (target.height / 2);
        var distX = targetCenterX - focusX;
        var distY = targetCenterY - focusY;
        var halfDeadzoneW = deadzoneWidth / 2;
        var halfDeadzoneH = deadzoneHeight / 2;

        var desiredFocusX = focusX;
        var desiredFocusY = focusY;

        if (distX > halfDeadzoneW) {
            desiredFocusX = targetCenterX - halfDeadzoneW;
        } else if (distX < -halfDeadzoneW) {
            desiredFocusX = targetCenterX + halfDeadzoneW;
        }

        if (distY > halfDeadzoneH) {
            desiredFocusY = targetCenterY - halfDeadzoneH;
        } else if (distY < -halfDeadzoneH) {
            desiredFocusY = targetCenterY + halfDeadzoneH;
        }


        focusX += (desiredFocusX - focusX) * lerpSpeed * dt;
        focusY += (desiredFocusY - focusY) * lerpSpeed * dt;

        updateWorldPosition();
    }

    public function updateWorldPosition():Void {
        x = -focusX + (screenWidth / 2) + offsetX;
        y = -focusY + (screenHeight / 2) + offsetY;

        world.x = x;
        world.y = y;
    }
}
