extends Control

#-- Assigned by system
var window_manager

#-- Scene Refs
onready var encoded_mod_text_edit = $Border2/BG/VBoxContainer/HBoxContainer/EncodedModTextEdit
onready var scan_button = $Border2/BG/VBoxContainer/ButtonContainer/ScanButton
onready var import_button = $Border2/BG/VBoxContainer/ButtonContainer/ImportButton

#--- Called when the window is added to the scene.
func _create():
	pass

#--- Called when the window is activated.
func _enable(_data):
	_on_EncodedModTextEdit_text_changed()
	pass

#--- Called when the window is deactivated.
func _disable():
	_on_ClearButton_pressed()
	pass

#--- Called when the window is removed from the scene.
func _destroy():
	pass

func _on_EncodedModTextEdit_text_changed():
	if encoded_mod_text_edit.text == "":
		scan_button.disabled = true
		import_button.disabled = true
	else:
		scan_button.disabled = false
	pass

func _on_ScanButton_pressed():
	var mod = Globals.get_manager("main").decode_mod(encoded_mod_text_edit.text)
	var console = Globals.get_manager("console")
	if scan(mod) == OK:
		import_button.disabled = false
		console.generate("Scan was successful! You can import this mod.", Globals.green)
	else:
		console.posterr("ERR666: Mod is not recognised! Please ensure what you are pasting is indeed a mod.")
	pass

func scan(modDecode):
	var gameExtension = Globals.get_manager("main").activeGame
	if modDecode == null:
		return ERR_CANT_OPEN
	elif modDecode.has("Game") && modDecode.Game == gameExtension.name:
		var failed = false
		if modDecode.Mod.has("fields"):
			for decodedCategory in modDecode.Mod.fields:
				var cateFail = true
				for category in gameExtension.data.Categories:
					if category.Title == decodedCategory:
						cateFail = false
						break
				if cateFail:
					failed = true
					break
		if failed:
			return ERR_CANT_OPEN
		else:
			return OK
	else:
		return ERR_CANT_OPEN
	pass

func _on_ImportButton_pressed():
	var mana = Globals.get_manager("main")
	var modDecode = mana.decode_mod(encoded_mod_text_edit.text)
	mana.add_mod(modDecode.Mod)
	
	_on_ClearButton_pressed()
	pass

func _on_ClearButton_pressed():
	encoded_mod_text_edit.text = ""
	_on_EncodedModTextEdit_text_changed()
	pass

func _on_CloseButton_pressed():
	window_manager.disable_window()
	pass

func _on_PasteButton_pressed():
	encoded_mod_text_edit.text = OS.clipboard
	_on_EncodedModTextEdit_text_changed()
	pass
