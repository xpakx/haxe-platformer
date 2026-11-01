package;

import starling.display.DisplayObject;

class Intersects {
    public static function intersects(first:DisplayObject, second:DisplayObject):Bool {
        var firstRight = first.x + first.width;
        var firstLeft = first.x;
        var firstTop = first.y;
        var firstBottom = first.y + first.height;

        var secondRight = second.x + second.width;
        var secondLeft = second.x;
        var secondTop = second.y;
        var secondBottom = second.y + second.height;
        return !(firstRight < secondLeft || 
                 firstLeft > secondRight || 
                 firstBottom < secondTop || 
                 firstTop > secondBottom);
    }
}
