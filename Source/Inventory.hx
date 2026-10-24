package;

enum EquipmentSlot {
    Head;
    Armor;
    Boots;
}

class Inventory {
    private var items:Array<String> = [];
    private var equipment:Map<EquipmentSlot, String> = new Map();

    private var head:String;
    private var armor:String;
    private var boots:String;

    public function new() {
    }

    public function add(itemId:String):Void {
        items.push(itemId);
    }

    public function equip(slot:EquipmentSlot, itemId:String):Void {
        equipment.set(slot, itemId);
    }

    public function getEquipped(slot:EquipmentSlot):String {
        return equipment.get(slot);
    }

    public function unequip(slot:EquipmentSlot):Void {
        equipment.remove(slot);
    }
}
