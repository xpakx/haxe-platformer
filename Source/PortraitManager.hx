package;

import openfl.utils.Assets;
import starling.textures.Texture;
import js.Browser;


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
        if (portraits.exists(key)) {
	    Browser.console.log("Portraits already loaded");
            return;
        }
        var path = "assets/" + name;
        var texture = Texture.fromData(Assets.getBitmapData(path));
	portraits.set(key, texture);
    }

    public function exists(key:String):Bool {
        return portraits.exists(key);
    }

    public function unloadPortrait(key:String):Void {
        if (portraits.exists(key)) {
            var texture = portraits.get(key);
            if (texture != null) texture.dispose();
            portraits.remove(key);
        }
    }

    public function dispose():Void {
        for (texture in portraits) {
            if (texture != null) {
                texture.dispose();
            }
        }
        portraits.clear();
    }
}
