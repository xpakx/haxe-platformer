package;

import openfl.utils.Assets;
import starling.textures.Texture;


class PortraitManager {
    private var portraits:Map<String, Texture> = new Map();

    public function new() {
    }

    public function get(key:String):Texture {
        return portraits.get(key);
    }

    public function initPortraits():Void {
        loadPortrait("test.png", "test");
    }

    public function loadPortrait(name:String, key:String) {
        var path = "assets/" + name;
        var texture = Texture.fromData(Assets.getBitmapData(path));
	portraits.set(key, texture);
    }
}
