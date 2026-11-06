package platform;

class CrumbleBehavior implements PlatformBehavior {
    private var crumbleDelay:Float;
    private var timer:Float = 0;
    private var crumblingInitiated:Bool = false;

    public function new(crumbleDelay:Float = 1.0) {
        this.crumbleDelay = crumbleDelay;
    }

    public function update(dt:Float, platform:Platform):Void {
        if (!crumblingInitiated) return;

        timer += dt;
        platform.x += (Math.random() * 4) - 2;

        if (timer >= crumbleDelay) {
            platform.visible = false;
	    platform.removed = true;
	    crumblingInitiated = false;
	    timer = 0;
        }
    }

    public function onLandedOn(platform:Platform):Void {
        crumblingInitiated = true;
    }
}
