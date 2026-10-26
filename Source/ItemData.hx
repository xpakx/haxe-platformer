package; 

enum ItemRarity {
    Common;
    Uncommon;
    Rare;
    Epic;
    Legendary;
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
