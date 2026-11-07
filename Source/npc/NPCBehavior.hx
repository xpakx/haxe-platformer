package npc;

interface NPCBehavior {
    function update(dt:Float, npc:NPC):Void;
    function onInteract(npc:NPC):Void;
}
