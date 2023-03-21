extends Node

#-- Scene Refs
onready var label = $HeaderLabel
onready var field:SpinBox = $SpinBox

#-- Assigned by System
var fieldData
var nextField

func set_focus():
	var fEdit = field.get_line_edit()
	fEdit.connect("text_entered", self, "_on_value_set")
	fEdit.grab_focus()
	if fEdit.text == "0":
		fEdit.text = ""
	pass

func get_value():
	return str(field.value)

func set_label(text:String):
	label.text = text

func _on_value_set(_text):
	if not nextField == null:
		nextField.set_focus()
	pass
