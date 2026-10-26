package;

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
