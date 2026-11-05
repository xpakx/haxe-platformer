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


    public function landedOn(x:Float, y:Float, width:Float, height:Float, nextX: Float, nextY: Float):Bool {
	var hitX = (x + width > this.x) && (x < this.x + this.width);
	var floor = this.y - height;
	var crossedTop = (y <= floor) && (nextY >= floor);
	return (hitX && crossedTop);
    }


    public function isOn(x:Float, y:Float, width:Float, height:Float):Bool {
            var hitX = (x + width > this.x) && (x < this.x + this.width);
	    var floor = this.y - height;
            var hitY = (y >= floor) && (y <= floor + 15);
            return (hitX && hitY);
 
    }
}
