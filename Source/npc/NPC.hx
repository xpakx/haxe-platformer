package npc;

import starling.display.Sprite;
import starling.display.Quad;


class NPC extends Sprite {
    private var visual:Quad;
    public var onInteraction: Void -> Void;
    public var interactionRange:Float = 0.0;

    public function new(x:Float, y:Float, width:Float, height:Float, color:Int = 0xFFD700) {
        super();
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        
        visual = new Quad(width, height, color);
        addChild(visual);
    }

    public function update(dt:Float):Void {
    }

    public function interact():Void {
        if (onInteraction != null) {
            onInteraction();
        }
    }
}
