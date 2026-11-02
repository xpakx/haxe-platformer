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

typedef DialogueChoice = {
    var text: String;
    var nextIndex: Int;
}

typedef DialogueLine = {
    var speaker: String;
    var text: String;
    @:optional var choices: Array<DialogueChoice>;
    @:optional var portraitId: String;
    @:optional var nextIndex: Int;
}

class DialogueBox extends Sprite {
    private var bg:DisplayObject;
    private var nameBox:DisplayObject;
    private var nameField:TextField;
    private var textField:TextField;

    private var dialogueQueue:Array<DialogueLine> = [];
    private var currentIndex:Int = 0;
    
    private var fullText:String = "";
    private var displayedCharCount:Int = 0;
    private var timer:Float = 0;
    private var textSpeed:Float = 0.03;
    private var isTyping:Bool = false;
    private var mode:DialogueBackgroundMode = Solid;

    public var onComplete:Void->Void;

    private static inline var TILE_SIZE:Int = 50;

    private var currentChoices:Array<DialogueChoice> = null;
    private var selectedChoiceIndex:Int = 0;
    private var choiceContainer:Sprite;
    private var choiceTextFields:Array<TextField> = [];

    private var portraitContainer:Sprite;
    private var portraitImage:Image;
    private static inline var PORTRAIT_SIZE:Int = 100;

    private var boxWidth:Float;
    private var boxHeight:Float;

    private var portraits:PortraitManager;

    public function new(stageWidth:Float, stageHeight:Float) {
        super();

        boxWidth = stageWidth - 100;
        boxHeight = 150;
        bg = createBackground(mode, boxWidth, boxHeight);
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

	var textPadding:Int = mode == Solid ? 20 : 20 + TILE_SIZE;
        var textWidth:Int = Std.int(boxWidth - 2*textPadding);
        var textHeight:Int = Std.int(boxHeight - 2*textPadding);
        textField = new TextField(textWidth, textHeight, "");
	textField.wordWrap = false;
        textField.x = bg.x + textPadding;
        textField.y = bg.y + textPadding;
        textField.format.font = "Verdana";
        textField.format.size = 30;
        textField.format.color = 0xFFFFFF;
        textField.format.horizontalAlign = "left";
        textField.format.verticalAlign = "top";
        addChild(textField);

        choiceContainer = new Sprite();
        choiceContainer.x = bg.x + bg.width - 120;
        choiceContainer.y = bg.y - 120;
        addChild(choiceContainer);

        portraitContainer = new Sprite();
        portraitContainer.x = bg.x + 20;
        portraitContainer.y = bg.y + (boxHeight - PORTRAIT_SIZE) / 2;
        var portraitBg = new Quad(PORTRAIT_SIZE, PORTRAIT_SIZE, 0x222222);
        portraitContainer.addChild(portraitBg);
        addChild(portraitContainer);
        portraitContainer.visible = false;

	portraits = new PortraitManager();
	portraits.initPortraits();
    }

    public function startDialogue(dialogueList:Array<DialogueLine>):Void {
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

        var hasSpeaker = line.speaker != null && line.speaker.length > 0;
        nameBox.visible = hasSpeaker;
        nameField.visible = hasSpeaker;
	if (hasSpeaker) nameField.text = line.speaker;

        var hasPortrait = line.portraitId != null && line.portraitId.length > 0;
        portraitContainer.visible = hasPortrait;
	var basePadding = mode == Solid ? 20 : 20 + TILE_SIZE;
        if (hasPortrait) {
            updatePortrait(line.portraitId);
            var leftOffset = basePadding + PORTRAIT_SIZE + 15;
            textField.x = bg.x + leftOffset;
            textField.width = Std.int(boxWidth - leftOffset - basePadding);
        } else {
            textField.x = bg.x + basePadding;
            textField.width = Std.int(boxWidth - 2 * basePadding);
        }

        clearChoices();
        currentChoices = line.choices;

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
                if (currentChoices != null && currentChoices.length > 0) {
                    displayChoices();
                }
            }
        }
    }

    public function handleInput(keyCode:Int):Void {
        if (!visible) return;

        if (currentChoices != null && currentChoices.length > 0 && !isTyping) {
	    handleChoice(keyCode);
	    return;
        }

        if (keyCode == Keyboard.SPACE || keyCode == Keyboard.ENTER) {
            if (isTyping) {
                isTyping = false;
                displayedCharCount = fullText.length;
                textField.text = fullText;
            } else {
		var line = dialogueQueue[currentIndex];
		if (line.nextIndex != null) {
		    currentIndex = line.nextIndex;
		} else {
                    currentIndex++;
		}
                showCurrentLine();
            }
        }
    }

    private function handleChoice(keyCode:Int):Void {
        if (keyCode == Keyboard.UP) {
            selectedChoiceIndex--;
            if (selectedChoiceIndex < 0) {
                selectedChoiceIndex = currentChoices.length - 1;
            }
            updateChoiceHighlight();
        }
        if (keyCode == Keyboard.DOWN) {
            selectedChoiceIndex++;
            if (selectedChoiceIndex >= currentChoices.length) {
                selectedChoiceIndex = 0;
            }
            updateChoiceHighlight();
        }
        if (keyCode == Keyboard.ENTER || keyCode == Keyboard.SPACE) {
            selectCurrentChoice();
        }
    }

    private function updateChoiceHighlight():Void {
        for (i in 0...choiceTextFields.length) {
            var tf = choiceTextFields[i];
            if (i == selectedChoiceIndex) {
                tf.format.color = 0x0000FF;
            } else {
                tf.format.color = 0x000000;
            }
        }
    }

    private function selectCurrentChoice():Void {
        if (currentChoices == null || selectedChoiceIndex < 0 || selectedChoiceIndex >= currentChoices.length) {
            return;
        }
        var chosen = currentChoices[selectedChoiceIndex];
        clearChoices();
        currentIndex = chosen.nextIndex;
        showCurrentLine();
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
                var texture = Texture.fromData(
                    Assets.getBitmapData("assets/dialogue_box.png")
                );
		return createTiledNineSlice(texture, width, height);
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

    private function createTiledNineSlice(
        texture:Texture,
        width:Float,
        height:Float
    ):DisplayObject {

        var result = new Sprite();

        var sw = texture.width / 3;
        var sh = texture.height / 3;

        var middleW = Math.max(0, width - 2*TILE_SIZE);
        var middleH = Math.max(0, height - 2*TILE_SIZE);

        var topLeft = new Rectangle(0, 0, sw, sh);
        var topRight = new Rectangle(2*sw, 0, sw, sh);
        var bottomLeft = new Rectangle(0, 2*sh, sw, sh);
        var bottomRight = new Rectangle(2*sw, 2*sh, sw, sh);
        var topMiddle = new Rectangle(sw, 0, sw, sh);
        var bottomMiddle = new Rectangle(sw, sh*2, sw, sh);
        var leftMiddle = new Rectangle(0, sh, sw, sh);
        var rightMiddle = new Rectangle(sw*2, sh, sw, sh);
        var middle = new Rectangle(sw, sh, sw, sh);

        addSlice(result, texture, topLeft, 0, 0);
        addSlice(result, texture, topRight, TILE_SIZE + middleW, 0);
        addSlice(result, texture, bottomLeft, 0, TILE_SIZE + middleH);
        addSlice(result, texture, bottomRight, TILE_SIZE + middleW, TILE_SIZE + middleH);

        addTiledSlice(result, texture, topMiddle, TILE_SIZE, 0, middleW, TILE_SIZE);
        addTiledSlice(result, texture, bottomMiddle, TILE_SIZE, TILE_SIZE + middleH, middleW, TILE_SIZE);

        addTiledSlice(result, texture, leftMiddle, 0, TILE_SIZE, TILE_SIZE, middleH);
        addTiledSlice(result, texture, rightMiddle, TILE_SIZE + middleW, TILE_SIZE, TILE_SIZE, middleH);
        addTiledSlice(result, texture, middle, TILE_SIZE, TILE_SIZE, middleW, middleH);


        return result;
    }

    private function addSlice(
        parent:Sprite,
        source:Texture,
	sourceRegion:Rectangle,
        x:Float,
	y:Float
    ):Void {
        var subTexture = Texture.fromTexture(source, sourceRegion);
        var image = new Image(subTexture);
        image.x = x;
        image.y = y;
        image.width = TILE_SIZE;
        image.height = TILE_SIZE;

        parent.addChild(image);
    }

    private function addTiledSlice(
        parent:Sprite,
        source:Texture,
	sourceRegion:Rectangle,
        x:Float, y:Float,
        width:Float, height:Float
    ):Void {

        if (width <= 0 || height <= 0) return;
    
        var sub = Texture.fromTexture(source, sourceRegion);

        var image = new Image(sub);
    
        image.x = x;
        image.y = y;

        image.width = width;
        image.height = height;

        image.tileGrid = new Rectangle(
            0, 0, TILE_SIZE, TILE_SIZE
        );

        parent.addChild(image);
    }


    private function displayChoices():Void {
        if (currentChoices == null || currentChoices.length == 0) return;

        selectedChoiceIndex = 0;
        choiceContainer.visible = true;

        for (i in 0...currentChoices.length) {
            var choice = currentChoices[i];
        
            var tf = new TextField(Std.int(bg.width - 40), 30, choice.text);
            tf.y = i * 35;
            tf.format.font = "Verdana";
            tf.format.size = 20;
            tf.format.color = (i == selectedChoiceIndex) ? 0x0000FF : 0x000000;
            tf.format.horizontalAlign = "left";
        
            choiceContainer.addChild(tf);
            choiceTextFields.push(tf);
        }
    }

    private function clearChoices():Void {
        choiceContainer.visible = false;
        for (tf in choiceTextFields) {
            choiceContainer.removeChild(tf);
            tf.dispose();
        }
        choiceTextFields = [];
        currentChoices = null;
    }


    private function updatePortrait(portraitId:String):Void {
        if (portraitImage != null) {
            portraitContainer.removeChild(portraitImage);
            portraitImage.dispose();
            portraitImage = null;
        }

        var path = "assets/" + portraitId + ".png";
        if (Assets.exists(path)) {
            var texture = Texture.fromData(Assets.getBitmapData(path));
            portraitImage = new Image(texture);
            portraitImage.width = PORTRAIT_SIZE;
            portraitImage.height = PORTRAIT_SIZE;
            portraitContainer.addChild(portraitImage);
        }
    }
}
