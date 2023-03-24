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
	
	if _data.has("info"):
		field.value = int(_data.info)
	
	var fEdit = field.get_line_edit()
	fEdit.connect("text_entered", self, "_on_value_set")
	fEdit.connect("focus_entered", self, "alt_focus")
	pass

func _on_value_set(_text):
	#- Force a frame wait to ensure value is set
	Functions.wait_frame()
	if not nextField == null:
		nextField.set_focus()
	pass
