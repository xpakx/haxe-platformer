package;

import starling.display.Sprite;
import starling.display.Quad;
import starling.text.TextField;
import starling.events.KeyboardEvent;
import starling.display.DisplayObject;
import openfl.ui.Keyboard;
import starling.display.Image;
import openfl.utils.Assets;
import openfl.geom.Rectangle;
import starling.textures.Texture;
import starling.text.TextFieldAutoSize;

enum DialogueBackgroundMode {
    Solid;
    NineSlice;
}

class DialogueBox extends Sprite {
    private var bg:DisplayObject;
    private var nameBox:DisplayObject;
    private var nameField:TextField;
    private var textField:TextField;

    private var dialogueQueue:Array<{ speaker: String, text: String }> = [];
    private var currentIndex:Int = 0;
    
    private var fullText:String = "";
    private var displayedCharCount:Int = 0;
    private var timer:Float = 0;
    private var textSpeed:Float = 0.03;
    private var isTyping:Bool = false;

    public var onComplete:Void->Void;

    public function new(stageWidth:Float, stageHeight:Float) {
        super();

        var boxWidth:Float = stageWidth - 100;
        var boxHeight:Float = 150;
        bg = createBackground(Solid, boxWidth, boxHeight);
        bg.x = 50;
        bg.y = stageHeight - boxHeight - 30;
        addChild(bg);

        var border = new Quad(boxWidth, 4, 0xFFFFFF);
        border.x = bg.x;
        border.y = bg.y;
        addChild(border);

        nameBox = new Quad(180, 35, 0x333333);
        nameBox.x = bg.x;
        nameBox.y = bg.y - 40;
        addChild(nameBox);

        nameField = new TextField(180, 35, "");
        nameField.x = nameBox.x;
        nameField.y = nameBox.y;
        nameField.format.font = "Verdana";
        nameField.format.size = 18;
        nameField.format.color = 0xFFFFFF;
        nameField.format.horizontalAlign = "center";
        nameField.format.verticalAlign = "center";
        addChild(nameField);

        var textWidth:Int = Std.int(boxWidth - 40);
        var textHeight:Int = Std.int(boxHeight - 40);
        textField = new TextField(textWidth, textHeight, "");
	textField.wordWrap = false;
        textField.x = bg.x + 20;
        textField.y = bg.y + 20;
        textField.format.font = "Verdana";
        textField.format.size = 30;
        textField.format.color = 0xFFFFFF;
        textField.format.horizontalAlign = "left";
        textField.format.verticalAlign = "top";
        addChild(textField);
    }

    public function startDialogue(dialogueList:Array<{ speaker: String, text: String }>):Void {
        dialogueQueue = dialogueList;
        currentIndex = 0;
        visible = true;
        showCurrentLine();
    }

    private function showCurrentLine():Void {
        if (currentIndex >= dialogueQueue.length) {
            closeDialogue();
            return;
        }

        var line = dialogueQueue[currentIndex];
        nameField.text = line.speaker;
        fullText = wrapText(line.text);
        displayedCharCount = 0;
        textField.text = "";
        isTyping = true;
        timer = 0;
    }

    public function update(dt:Float):Void {
        if (!visible || !isTyping) return;

        timer += dt;
        if (timer >= textSpeed) {
            timer = 0;
            displayedCharCount++;
            textField.text = fullText.substr(0, displayedCharCount);

            if (displayedCharCount >= fullText.length) {
                isTyping = false;
            }
        }
    }

    public function handleInput(keyCode:Int):Void {
        if (!visible) return;

        if (keyCode == Keyboard.SPACE || keyCode == Keyboard.ENTER) {
            if (isTyping) {
                isTyping = false;
                displayedCharCount = fullText.length;
                textField.text = fullText;
            } else {
                currentIndex++;
                showCurrentLine();
            }
        }
    }

    private function closeDialogue():Void {
        visible = false;
        if (onComplete != null) {
            onComplete();
        }
    }

    private function createBackground(
        mode:DialogueBackgroundMode, width:Float, height:Float):DisplayObject {


        switch (mode) {
            case Solid:
                var quad = new Quad(width, height, 0x000000);
	        quad.alpha = 0.8;
	        return quad;
            case NineSlice:
	        // TODO: bultin 9slice streches tiles instead of repeating

                var texture = Texture.fromData(
                    Assets.getBitmapData("assets/dialogue_box.png")
                );
                var image = new Image(texture);

                image.scale9Grid = new Rectangle(
                    texture.width / 3,
                    texture.height / 3,
                    texture.width / 3,
                    texture.height / 3
                );

                image.width = width;
                image.height = height;
                return image;
        }
    }


    private function wrapText(text:String):String {
        var words = text.split(" ");
        var lines:Array<String> = [];
        var currentLine = "";

        var measureField = new TextField(1, 40, "");
        measureField.format = textField.format;
        measureField.wordWrap = false;
        measureField.autoSize = TextFieldAutoSize.HORIZONTAL;

        for (word in words) {
            var testLine = currentLine == "" ? word : currentLine + " " + word;

            measureField.text = testLine;

            if (measureField.width > textField.width && currentLine != "") {
                lines.push(currentLine);
                currentLine = word;
            } else {
                currentLine = testLine;
            }
        }

        if (currentLine != "") {
            lines.push(currentLine);
        }

        measureField.dispose();

        return lines.join("\n");
    }
}
