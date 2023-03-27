extends Control

#-- Constants
const my_id = "tab"

#-- Scene Refs
onready var details_container = $"../../Background/VBoxContainer/VSplitContainer/HSplitContainer/DetailsContainer"
onready var general = $"../../Background/VBoxContainer/VSplitContainer/HSplitContainer/DetailsContainer/Tab/General"

func jump_start():
	Globals.set_manager(my_id, self)
	general.tab_manager = self
	general.jump_start()
	pass

func fresh_session():
	Session.data["General"] = general.get_fresh_general()
	pass

func session_launched():
	general.session_launched()
	pass

func _on_CheckButton_toggled(button_pressed):
	details_container.visible = button_pressed
	pass
