package npc;

import starling.display.Sprite;
import starling.display.Quad;


class NPC extends Sprite {
    private var visual:Quad;
    public var onInteraction: Void -> Void;
    private var behaviors:Array<NPCBehavior> = [];
    public var interactionRange:Float = 0.0;

    public var flags:Map<String, Bool> = [];
    public var id:String;
    public var npcName:String;

    public function new(x:Float, y:Float, width:Float, height:Float, color:Int = 0xFFD700) {
        super();
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        
        visual = new Quad(width, height, color);
        addChild(visual);
    }

    public function addBehavior(behavior:NPCBehavior):NPC {
        behaviors.push(behavior);
        return this;
    }

    public function removeBehavior(behavior:NPCBehavior):Bool {
        return behaviors.remove(behavior);
    }

    public function getBehavior<T:NPCBehavior>(cls:Class<T>):T {
        for (b in behaviors) {
            if (Std.isOfType(b, cls)) {
                return cast b;
            }
        }
        return null;
    }

    public function update(dt:Float):Void {
        for (b in behaviors) {
            b.update(dt, this);
        }
    }

    public function interact():Void {
        if (onInteraction != null) {
            onInteraction();
        }
        for (b in behaviors) {
            b.onInteract(this);
        }
    }

    public function setFlag(key:String):Void {
        flags.set(key, true);
    }

    public function getFlag(key:String):Bool {
        return flags.exists(key) ? flags.get(key) : false;
    }

    public function unsetFlag(key:String):Void {
        flags.set(key, false);
    }
}
