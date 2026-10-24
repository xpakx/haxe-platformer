package;

class Inventory {
    private var items:Array<String> = [];

    private var head:String;
    private var armor:String;
    private var boots:String;

    public function new() {
    }

    public function add(itemId:String):Void {
        items.push(itemId);
    }
}
