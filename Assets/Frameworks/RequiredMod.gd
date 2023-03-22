extends Node

#-- Scene Refs
onready var mod_name_text = $Fields/ModNameText
onready var mod_link_text = $Fields/ModLinkText

#-- Assigned by System
var modADriver
var listIndex

func get_data():
	var data = {
		"Name":mod_name_text.text,
		"Link":mod_link_text.text
	}
	return data

func drop_index():
	listIndex -= 1
	pass

func _on_DeleteButton_pressed():
	modADriver.remove_required(listIndex)
	pass
