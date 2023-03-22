extends Node

#-- Scene Refs
onready var label = $HeaderLabel
onready var field:OptionButton = $OptionButton

#-- Assigned by System
var fieldData
var nextField

func set_focus():
	field.grab_focus()
	pass

func get_value():
	return field.text

func set_data(labelText:String, data = null):
	label.text = labelText
	set_options(data)
	pass

func set_options(options):
	for option in options:
		field.add_item(option)
	pass
