extends Node

#-- Scene Refs
onready var label = $HeaderLabel
onready var field = $LineEdit

#-- Assigned by System
var fieldData
var nextField

func set_focus():
	field.grab_focus()
	pass

func get_value():
	return field.text

func set_label(text:String):
	label.text = text

func _on_LineEdit_text_entered(_new_text):
	if not nextField == null:
		nextField.set_focus()
	pass
