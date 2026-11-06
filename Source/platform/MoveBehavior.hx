package platform;

class MoveBehavior implements PlatformBehavior {
    private var startX:Float;
    private var endX:Float;
    private var speed:Float;
    private var travelTimer:Float = 0;

    public function new(startX:Float, endX:Float, speed:Float) {
        this.startX = startX;
        this.endX = endX;
        this.speed = speed;
    }

    public function update(dt:Float, platform:Platform):Void {
        travelTimer += dt * speed;
        var oldX = platform.x;
        var offset = Math.sin(travelTimer) * (endX - startX) / 2;
        var mid = startX + (endX - startX) / 2;
        
        platform.x = mid + offset;
        platform.vx = platform.x - oldX;
    }

    public function onLandedOn(platform:Platform):Void {}
}
