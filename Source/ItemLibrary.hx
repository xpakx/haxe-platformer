package;


class ItemLibrary {
    private static var registry:Map<String, ItemData> = new Map();
    private static var initialized:Bool = false;

    public static function register(item:ItemData):Void {
        registry.set(item.id, item);
    }

    public static function get(id:String):ItemData {
        return registry.get(id);
    }

    public static function init():Void {
        if (initialized) return;
        
        register(new ItemData("iron_helm", "Iron Helmet", "Test", EquipmentSlot.Head));
        register(new ItemData("steel_armor", "Steel Armor", "Test", EquipmentSlot.Armor));
        register(new ItemData("leather_boots", "Leather Boots", "Test", EquipmentSlot.Boots));
        register(new ItemData("health_potion", "Health Potion", "Test"));
        register(new ItemData("speed_boots", "Boots of Speed", "Test", EquipmentSlot.Boots,
	[new StatModifier(StatType.Speed, 50, true)],
	Common,
	[DoubleJumpAbility],
	));

        register(new ItemData("cape", "Cape", "Test", EquipmentSlot.Armor,
	[],
	Common,
	[FloatAbility],
	));


        initialized = true;
    }
}
