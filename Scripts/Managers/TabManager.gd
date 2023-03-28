extends Control

#-- Constants
const my_id = "tab"

#-- Scene Refs
onready var details_container = $"../../Background/VBoxContainer/VSplitContainer/HSplitContainer/DetailsContainer"
onready var general = $"../../Background/VBoxContainer/VSplitContainer/HSplitContainer/DetailsContainer/Tab/General"
onready var resources = $"../../Background/VBoxContainer/VSplitContainer/HSplitContainer/DetailsContainer/Tab/Resources"

func jump_start():
	Globals.set_manager(my_id, self)
	
	#- Assign tab_manager to each tab.
	general.tab_manager = self
	resources.tab_manager = self
	
	#- Initiate each tab.
	general.jump_start()
	resources.jump_start()
	pass

func fresh_session():
	Session.data["General"] = general.get_fresh()
	Session.data["Resources"] = resources.get_fresh()
	pass

func session_launched():
	general.session_launched()
	resources.session_launched()
	pass

func _on_CheckButton_toggled(button_pressed):
	details_container.visible = button_pressed
	pass
