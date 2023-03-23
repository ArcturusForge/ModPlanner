extends Control

#-- Assigned by system
var window_manager

#-- Scene Refs
var mainManager
var searchManager

#--- Called when the window is added to the scene.
func _create():
	mainManager = Globals.get_manager("main")
	searchManager = Globals.get_manager("search")
	pass

#--- Called when the window is activated.
func _enable(_data):
	pass

#--- Called when the window is deactivated.
func _disable():
	pass

#--- Called when the window is removed from the scene.
func _destroy():
	pass

func _on_NewSessionButton_pressed():
	window_manager.activate_window("gameSelect")
	pass

func _on_LoadSessionButton_pressed():
	searchManager.search_for_session(self, "open_loaded_session")
	pass

func open_loaded_session(filePath:String):
	mainManager.open_loaded_session(filePath)
	window_manager.disable_window()
	pass
