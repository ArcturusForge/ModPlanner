extends Node

#-- Scene Refs
onready var label = $HeaderLabel
onready var field:SpinBox = $SpinBox

#-- Assigned by System
var fieldData
var nextField

func set_focus():
	var fEdit = field.get_line_edit()
	fEdit.grab_focus()
	if fEdit.text == "0":
		fEdit.text = ""
	pass

func alt_focus():
	var fEdit = field.get_line_edit()
	if fEdit.text == "0":
		fEdit.text = ""
	pass

func get_value():
	return str(field.value)

func set_data(labelText:String, _data = null):
	label.text = labelText
	
	var fEdit = field.get_line_edit()
	fEdit.connect("text_entered", self, "_on_value_set")
	fEdit.connect("focus_entered", self, "alt_focus")
	pass

func _on_value_set(_text):
#	var fEdit = field.get_line_edit()
#	fEdit.text = _text
	#- Force a frame wait to ensure value is set
	yield(get_tree().create_timer(0.001), "timeout")
	if not nextField == null:
		nextField.set_focus()
	pass
