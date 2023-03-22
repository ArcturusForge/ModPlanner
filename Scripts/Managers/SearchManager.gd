extends Control

#-- Constants
const my_id = "search"

#-- Scene Refs
onready var file_dialog = $"../../FileSearchWindows/FileDialog"

#-- Signals
#- Called when a file is selected
signal on_file(filePath)

func jump_start():
	Globals.set_manager(my_id, self)
	file_dialog.connect("file_selected", self, "file_selected")
	pass

func file_selected(filepath):
	emit_signal("on_file", filepath)
	pass

func search_for_session():
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.filters = ["*.mplan"]
	file_dialog.dialog_text = "Select a .mplan session to load..."
	file_dialog.window_title = "Load a Session"
	file_dialog.popup()
	pass
