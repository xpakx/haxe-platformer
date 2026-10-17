package;

import starling.display.Sprite;
import openfl.utils.Assets;
import starling.core.Starling;
import js.Browser;

import spine.atlas.TextureAtlas;
import spine.SkeletonData;
import spine.starling.StarlingTextureLoader;
import spine.starling.SkeletonSprite;

class SpineCharacter extends Sprite {
    private var skeletonSprite:SkeletonSprite;
    private var running:Bool = false;

    public function new() {
        super();
        initSpine();
    }

    private function initSpine():Void {
        var atlas = new TextureAtlas(
            Assets.getText("assets/hero.atlas"),
            new StarlingTextureLoader("assets/hero.atlas")
        );

        var skeletonData = SkeletonData.from(
            Assets.getText("assets/hero.json"),
            atlas
        );

        skeletonSprite = new SkeletonSprite(skeletonData);

        skeletonSprite.state.setAnimationByName(0, "idle", true);
	skeletonSprite.state.data.defaultMix = 0.2;

	Browser.console.log("--- Available Spine Animations ---");
        for (anim in skeletonData.animations) {
            Browser.console.log("Animation found: " + anim.name);
        }

        addChild(skeletonSprite);
	Starling.current.juggler.add(skeletonSprite);
    }

   public override function dispose():Void {
        if (skeletonSprite != null) {
            Starling.current.juggler.remove(skeletonSprite);
        }
        super.dispose();
    }

   public function startRun():Void {
       if (skeletonSprite == null) return;
       if (running) return;
       running = true;
       skeletonSprite.state.setAnimationByName(0, "walk", true);
   }

   public function endRun():Void {
       if (skeletonSprite == null) return;
       if (!running) return;
       running = false;
       skeletonSprite.state.setAnimationByName(0, "idle", true);
   }
   
   public function startJump():Void {
       if (skeletonSprite == null) return;
       skeletonSprite.state.setAnimationByName(0, "jump", true);
   }
}

