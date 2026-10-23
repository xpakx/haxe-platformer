package;

import starling.display.Sprite;
import starling.display.Quad;
import starling.text.TextField;
import starling.events.KeyboardEvent;
import openfl.ui.Keyboard;

class DialogueBox extends Sprite {
    private var bg:Quad;
    private var nameBox:Quad;
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
        bg = new Quad(boxWidth, boxHeight, 0x000000);
        bg.alpha = 0.8;
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
        textField.x = bg.x + 20;
        textField.y = bg.y + 20;
        textField.format.font = "Verdana";
        textField.format.size = 20;
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
        fullText = line.text;
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
}
