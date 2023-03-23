extends Control

#-- Constants
const my_id = "search"

#-- Scene Refs
onready var file_dialog = $"../../FileSearchWindows/FileDialog"

func jump_start():
	Globals.set_manager(my_id, self)
	pass

func search_for_session(target, method:String):
	reset_connections()
	file_dialog.connect("file_selected", target, method)
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.filters = ["*.mplan"]
	file_dialog.dialog_text = "Select a .mplan session to load..."
	file_dialog.window_title = "Load a Session"
	file_dialog.popup()
	pass

func search_to_save(target, method:String):
	reset_connections()
	file_dialog.connect("file_selected", target, method)
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.filters = ["*.mplan"]
	file_dialog.dialog_text = "Select a location to save your session..."
	file_dialog.window_title = "Save Session"
	file_dialog.popup()
	pass

func reset_connections():
	var connected = file_dialog.get_signal_connection_list("file_selected")
	for conn in connected:
		file_dialog.disconnect(conn.signal, conn.target, conn.method)
	pass
