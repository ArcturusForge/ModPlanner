extends Control

#-- Assigned by system
var window_manager

#-- Scene Refs
var mainManager

#-- Dynamic Vars
var modData = {}

#--- Called when the window is added to the scene.
func _create():
	mainManager = Globals.get_manager("main")
	pass

#--- Called when the window is activated.
func _enable():
	pass

#--- Called when the window is deactivated.
func _disable():
	modData = {}
	pass

#--- Called when the window is removed from the scene.
func _destroy():
	pass

func _on_AddButton_pressed():
	mainManager.add_mod()
	pass

func _on_CancelButton_pressed():
	window_manager.disable_window()
	pass
