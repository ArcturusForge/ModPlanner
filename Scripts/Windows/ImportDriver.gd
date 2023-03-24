extends Control

#-- Assigned by system
var window_manager

#-- Prefabs
const checkboxList = "res://Assets/Prefabs/Misc/ModImportList.tscn"
const importCheckbox = "res://Assets/Prefabs/Misc/ModImportCheckBox.tscn"

#-- Scene Refs
onready var scroll_container = $Border2/BG/ModImportContainer/ScrollContainer


#-- Dynamic Vars
var imports = []
var importList

#--- Called when the window is added to the scene.
func _create():
	pass

#--- Called when the window is activated.
func _enable(_data):
	importList = Functions.get_from_prefab(checkboxList)
	scroll_container.add_child(importList)
	
	for mod in _data:
		var inst = Functions.get_from_prefab(importCheckbox)
		importList.add_child(inst)
		inst.text = Globals.get_manager("main").get_mod_name(mod)
		imports.append({
			"check":inst,
			"mod":mod
		})
	pass

#--- Called when the window is deactivated.
func _disable():
	importList.queue_free()
	imports.clear()
	pass

#--- Called when the window is removed from the scene.
func _destroy():
	pass

func _on_CancelButton_pressed():
	window_manager.disable_window()
	pass

func _on_ConfirmButton_pressed():
	Globals.get_manager("console").generate("Importing mods...", Globals.green)
	for import in imports:
		if import.check.pressed:
			Globals.get_manager("main").add_mod(import.mod)
	window_manager.disable_window()
	pass
