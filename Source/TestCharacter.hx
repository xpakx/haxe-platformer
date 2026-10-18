package;

import starling.display.Sprite;
import starling.display.Quad;
import starling.core.Starling;
import js.Browser;

class TestCharacter extends Sprite {
    private var rect:Quad;

    public function new() {
        super();
        init();
    }

    private function init():Void {
        rect = new Quad(80, 120, 0xCCCCCC);
        addChild(rect);
	endRun();
    }


   public function startRun():Void {
       rect.color = 0x0066FF;
   }

   public function endRun():Void {
       rect.color = 0xCCCCCC;
   }
   
   public function startJump():Void {
       rect.color = 0x00CC44;
   }

   public function startFall():Void {
       rect.color = 0xFF3333;
   }
}

