package;

class ItemData {
    public var id:String;
    public var name:String;
    public var description:String;
    public var slot:Null<EquipmentSlot>;

    public function new(id:String, name:String, description:String, ?slot:EquipmentSlot) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.slot = slot;
    }
}

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

        initialized = true;
    }
}
