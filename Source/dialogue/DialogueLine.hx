package dialogue;

typedef DialogueLine = {
    var speaker: String;
    var text: String;
    @:optional var choices: Array<DialogueChoice>;
    @:optional var portraitId: String;
    @:optional var nextIndex: Int;
}
