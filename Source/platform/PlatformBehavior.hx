package platform;

interface PlatformBehavior {
    function update(dt:Float, platform:Platform):Void;
    function onLandedOn(platform:Platform):Void;
}
