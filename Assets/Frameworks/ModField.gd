extends Node

#-- Scene Refs
onready var label
onready var field

#-- Assigned by System
var fieldData
var nextField

func set_focus():
	field.grab_focus()
	pass

func get_value():
	#return field.text/value
	pass

func set_data(labelText:String, _data = null):
	label.text = labelText
	pass
