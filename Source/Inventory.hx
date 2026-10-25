package;

import js.Browser;

class Inventory {
    private var items:Array<String> = [];
    private var equipment:Map<EquipmentSlot, String> = new Map();

    private var head:String;
    private var armor:String;
    private var boots:String;

    public function new() {
        ItemLibrary.init();
    }

    public function add(itemId:String):Void {
	var data = ItemLibrary.get(itemId);
        if (data == null) {
            return;
        }

        Browser.console.log("Equipped item: " + data.name);
        Browser.console.log("Rarity: " + data.rarity);
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

    public function equipFromInventory(index:Int, slot:EquipmentSlot):Bool {
        if (index < 0 || index >= items.length) return false;
        var itemId = items[index];
        var itemData = ItemLibrary.get(itemId);
        if (itemData == null || itemData.slot != slot) {
            return false; 
        }

        var oldItem = equipment.get(slot);
        if (oldItem != null) {
            items[index] = oldItem;
        } else {
            items.splice(index, 1);
        }

        equipment.set(slot, itemId);
        return true;
    }

    public function unequipToInventory(slot:EquipmentSlot):Bool {
        var itemId = equipment.get(slot);
        if (itemId == null) return false;

        items.push(itemId);
        equipment.remove(slot);
        return true;
    }
}
