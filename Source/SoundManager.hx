package;

import openfl.media.Sound;
import openfl.utils.Assets;
import openfl.media.SoundChannel;
import openfl.events.Event;


class SoundManager {
    private var soundLibrary:Map<String, Sound> = new Map();
    private var activeChannels:Map<String, SoundChannel> = new Map();

    public function new() {
    }

    public function play(key:String) {
        var sound = soundLibrary.get(key);
	if (sound == null) return;
        var channel = sound.play(0, 0);
        if (channel != null) {
            activeChannels.set(key, channel);
            channel.addEventListener(Event.SOUND_COMPLETE, function(_) {
                activeChannels.remove(key);
            });
        }
    }

    public function stop(key:String):Void {
        if (!activeChannels.exists(key)) return;
        activeChannels.get(key).stop();
        activeChannels.remove(key);
    }

    public function initSounds():Void {
        var jumpSound = Assets.getSound("audio/jump.ogg");
	soundLibrary.set("jump", jumpSound);
    }
}
