package platform;

import starling.display.Sprite;
import starling.display.Quad;

class Platform extends Sprite {
    private var visual:Quad;

    public function new(x:Float, y:Float, width:Float, height:Float) {
        super();
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
	visual = new Quad(width, height,0x555555);
        addChild(visual);
    }

    public function update(dt:Float):Void {
    }
}
