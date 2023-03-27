extends ColorRect

#-- Scene Refs
onready var extension_label = $ScrollContainer/VBoxContainer/HBoxContainer/ExtensionLabel
onready var version_line_edit = $ScrollContainer/VBoxContainer/HBoxContainer2/VersionLineEdit
onready var description_line_edit = $ScrollContainer/VBoxContainer/HBoxContainer5/DescriptionLineEdit

#-- Managers
var tab_manager

func jump_start():
	pass

func get_fresh_general():
	var data = {
		"Version":"",
		"Description":""
	}
	return data

#- Called by the system when a session has been started.
func session_launched():
	var mana = Globals.get_manager("main")
	extension_label.text = mana.activeGame.name
	
	if not Session.data.has("General"):
		Session.data["General"] = get_fresh_general()
	
	version_line_edit.text = Session.data.General.Version
	description_line_edit.text = Session.data.General.Description
	pass

func _on_VersionLineEdit_text_changed(new_text):
	Session.data.General.Version = new_text
	Globals.repaint_app_name(true)
	pass

func _on_DescriptionLineEdit_text_changed():
	Session.data.General.Description = description_line_edit.text
	Globals.repaint_app_name(true)
	pass
