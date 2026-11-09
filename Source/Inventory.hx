package;

import js.Browser;
import item.ItemData;
import item.ItemLibrary;
using DefaultMap;

class Inventory {
    private var items:Array<String> = [];
    private var equipment:Map<EquipmentSlot, String> = new Map();
    private var maxCapacity:Int;

    public var effectProvidersCount: Map<SpecialEffect, Int> = new Map();

    public function new() {
        maxCapacity = 30;
        ItemLibrary.init();
    }

    public function add(itemId:String):Bool {
	var data = ItemLibrary.get(itemId);
        if (data == null) {
            return false;
        }
	var equipped = autoequip(data);
	if (equipped) return true;

        if (items.length >= maxCapacity) {
            Browser.console.log("Inventory is full!");
            return false;
        }

        items.push(itemId);
	return true;
    }

    public function getEquipped(slot:EquipmentSlot):String {
        return equipment.get(slot);
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
            var oldItemData = ItemLibrary.get(oldItem);
            if (oldItemData != null) {
                removeEffectProvider(oldItemData);
            }
            items[index] = oldItem;
        } else {
            items.splice(index, 1);
        }

        equipment.set(slot, itemId);

	addEffectProvider(itemData);

        return true;
    }

    private function addEffectProvider(itemData:ItemData):Void {
        if (itemData.special == null) return;
	for (itemEffect in itemData.special) {
	    var val = effectProvidersCount.getOrSet(itemEffect, 0); 
	    val += 1;
	    effectProvidersCount.set(itemEffect, val); 
	}
    }

    private function removeEffectProvider(itemData:ItemData):Void {
        if (itemData.special == null) return;
	for (itemEffect in itemData.special) {
            var val = effectProvidersCount.getOrSet(itemEffect, 0); 
	    val -= 1;
	    if (val < 0) val = 0;
	    effectProvidersCount.set(itemEffect, val); 
	}
    }

    public function unequipToInventory(slot:EquipmentSlot):Bool {
        if (items.length >= maxCapacity) {
            Browser.console.log("Inventory is full, cannot unequip!");
            return false;
        }
        var itemId = equipment.get(slot);
        if (itemId == null) return false;

        items.push(itemId);
        equipment.remove(slot);

        var itemData = ItemLibrary.get(itemId);
	removeEffectProvider(itemData);

        return true;
    }

    public function hasEffect(effect: SpecialEffect): Bool {
        var count = effectProvidersCount.get(effect);
        return count != null && count > 0;
    }

    public function autoequip(data:ItemData):Bool {
       if (data.slot == null) return false;
       if (equipment.get(data.slot) != null) return false;
       equipment.set(data.slot, data.id);
       addEffectProvider(data);
       return true;
    }
}
