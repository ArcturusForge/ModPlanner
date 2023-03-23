extends Node

#-- Scene Refs
onready var mod_name_text = $Fields/ModNameText
onready var mod_link_text = $Fields/ModLinkText
onready var patchable_check_box:CheckBox = $Fields/PatchableCheckBox
onready var patch_link_header = $Fields/PatchLinkHeader
onready var patch_link_text = $Fields/PatchLinkText

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
	patchable_check_box.pressed = extraData.Patchable
	patch_link_text.text = extraData.Patch
	pass

func get_data():
	if not patchable_check_box.pressed:
		patch_link_text.text = ""
	
	var data = {
		"Name":mod_name_text.text,
		"Link":mod_link_text.text,
		"Patchable":patchable_check_box.pressed,
		"Patch":patch_link_text.text
	}
	return data

func drop_index():
	listIndex -= 1
	pass

func _on_DeleteButton_pressed():
	modADriver.remove_incompatible(listIndex)
	self.queue_free()
	pass

func _on_PatchableCheckBox_toggled(button_pressed):
	match button_pressed:
		true:
			patch_link_header.visible = true
			patch_link_text.visible = true
		false:
			patch_link_header.visible = false
			patch_link_text.visible = false
	pass
