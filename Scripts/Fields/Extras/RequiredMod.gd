extends Node

#-- Scene Refs
onready var mod_name_text = $Fields/ModNameText
onready var mod_link_text = $Fields/ModLinkText

#-- Assigned by System
var modADriver
var listIndex

func construct(driver, index, extraData):
	modADriver = driver
	listIndex = index
	
	if extraData == null:
		return
	
	# Assign existing data
	mod_name_text.text = extraData.Name
	mod_link_text.text = extraData.Link
	pass

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
	self.queue_free()
	pass
