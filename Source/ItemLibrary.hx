package;

enum StatType {
    Attack;
    Defense;
    MaxHealth;
    Speed;
}

enum ItemRarity {
    Common;
    Uncommon;
    Rare;
    Epic;
    Legendary;
}

class StatModifier {
    public var stat:StatType;
    public var value:Float;
    public var isPercentage:Bool;

    public function new(stat:StatType, value:Float, isPercentage:Bool = false) {
        this.stat = stat;
        this.value = value;
        this.isPercentage = isPercentage;
    }
}

class ItemData {
    public var id:String;
    public var name:String;
    public var description:String;
    public var slot:Null<EquipmentSlot>;
    public var effects:Array<StatModifier>;
    public var rarity:ItemRarity;
    public var special:Array<SpecialEffect>;

    public function new(
        id:String, name:String, description:String,
	?slot:EquipmentSlot, ?effects:Array<StatModifier>,
	?rarity:ItemRarity, ?special:Array<SpecialEffect>) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.slot = slot;
        this.effects = effects != null ? effects : [];
	this.rarity = rarity != null ? rarity : Common;
        this.special = special != null ? special : [];
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
        register(new ItemData("speed_boots", "Boots of Speed", "Test", EquipmentSlot.Boots,
	[new StatModifier(StatType.Speed, 50, true)],
	Common,
	[DoubleJumpAbility],
	));


        initialized = true;
    }
}
