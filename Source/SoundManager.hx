package;

import openfl.media.Sound;
import openfl.utils.Assets;


class SoundManager {
    private var soundLibrary:Map<String, Sound> = new Map();

    public function new() {
    }

    public function play(key:String) {
        var sound = soundLibrary.get(key);
	if (sound == null) return;
        sound.play(0, 0);
    }


    public function initSounds():Void {
        var jumpSound = Assets.getSound("audio/jump.ogg");
	soundLibrary.set("jump", jumpSound);
    }
}
