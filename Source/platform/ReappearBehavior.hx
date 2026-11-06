package platform;

class ReappearBehavior implements PlatformBehavior {
    private var respawnDelay:Float;
    private var timer:Float = 0;
    private var isWaitingToRespawn:Bool = false;

    public function new(respawnDelay:Float = 3.0) {
        this.respawnDelay = respawnDelay;
    }

    public function update(dt:Float, platform:Platform):Void {
        if (platform.removed && !isWaitingToRespawn) {
            isWaitingToRespawn = true;
            timer = 0;
        }

        if (isWaitingToRespawn) {
            timer += dt;
            if (timer >= respawnDelay) {
                platform.removed = false;
                platform.visible = true;
                isWaitingToRespawn = false;
            }
        }
    }

    public function onLandedOn(platform:Platform):Void {
    }
}
