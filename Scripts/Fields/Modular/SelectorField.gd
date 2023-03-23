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
	set_options(data.selector, data)
	pass

func set_options(options, data = null):
	var preselect = 0
	for i in range(options.size()):
		var option = options[i]
		if not data == null && data.has("info") && data.info == option:
			preselect = i
		field.add_item(option)
	field.select(preselect)
	pass
