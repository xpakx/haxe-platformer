package;

import starling.display.Sprite;
import starling.text.TextField;

class HUDLayer extends Sprite {
    private var scoreField:TextField;
    private var cachedScore:Int;

    public function new(stageWidth:Float) {
        super();

        scoreField = new TextField(200, 40, "Score: 0");
        scoreField.x = 20;
        scoreField.y = 20;
        scoreField.format.font = "Verdana";
        scoreField.format.size = 18;
        scoreField.format.color = 0x000000;
        scoreField.format.horizontalAlign = "left";
        scoreField.format.verticalAlign = "top";
        addChild(scoreField);
    }

    public function updateScore(newScore:Int):Void {
        if (cachedScore == newScore) return;
        scoreField.text = "Score: " + newScore;
	cachedScore = newScore;
    }
}
