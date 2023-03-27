extends Node

#-- Scene Refs
onready var mod_name_text = $Fields/ModNameText
onready var mod_link_text = $Fields/ModLinkText
onready var overwrite_selector = $Fields/OverwriteSelector

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
	#- Do Overwrite = 0, Get Overwritten = 1
	if not extraData.has("Overwrite"):
		extraData.Overwrite = "Do"
	var selIndex = 0 if "Do" in extraData.Overwrite else 1
	overwrite_selector.select(selIndex)
	pass

func get_data():
	var data = {
		"Name":mod_name_text.text,
		"Link":mod_link_text.text,
		"Overwrite":overwrite_selector.text
	}
	return data

func drop_index():
	listIndex -= 1
	pass

func _on_DeleteButton_pressed():
	modADriver.remove_compatible(listIndex)
	self.queue_free()
	pass
