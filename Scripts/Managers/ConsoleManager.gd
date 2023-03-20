extends Control

#-- Constants
const my_id = "console"

#-- Colors
var grey = "#b2b5bb"
var red = "#a25062"
var yellow = "#b7ab7c"

#-- Scene Refs
onready var rich_text_label = $"../../Background/VBoxContainer/VSplitContainer/ConsoleBGBorder/ConsoleBG/TextBG/ScrollContainer/RichTextLabel"

func jump_start():
	Globals.set_manager(my_id, self)
	pass

func generate(msg:String, colorHex:String):
	msg = "[color="+ colorHex +"]" + msg + "[/color]"
	if rich_text_label.text.length() > 0:
		rich_text_label.bbcode_text += "\n" + msg
	else:
		rich_text_label.bbcode_text += msg
	pass

func post(msg:String):
	generate(msg, grey)
	pass

func posterr(msg:String):
	generate(msg, red)
	pass

func postwrn(msg:String):
	generate(msg, yellow)
	pass

func _on_ClearButton_pressed():
	rich_text_label.bbcode_text = ""
	pass
