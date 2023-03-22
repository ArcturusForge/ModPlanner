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

func get_data():
	if not patchable_check_box.pressed:
		patch_link_text.text = ""
	
	var data = {
		"Name":"Goodbye World",
		"Link":"www.nexusmods.com/skyrim_se/goodbye_world_mod",
		"Patchable":patchable_check_box.pressed,
		"Patch":patch_link_text.text
	}
	return data

func drop_index():
	listIndex -= 1
	pass

func _on_DeleteButton_pressed():
	modADriver.remove_incompatible(listIndex)
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
