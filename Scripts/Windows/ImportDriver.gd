extends Control

#-- Assigned by system
var window_manager

#-- Prefabs
const checkboxList = "res://Assets/Prefabs/Misc/ModImportList.tscn"
const importCheckbox = "res://Assets/Prefabs/Misc/ModImportCheckBox.tscn"
const alertImg = "res://Assets/Graphics/64x64/alert.png"
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
	
	for impMod in _data:
		var inst:CheckBox = Functions.get_from_prefab(importCheckbox)
		importList.add_child(inst)
		inst.text = Globals.get_manager("main").get_mod_name(impMod)
		for mod in Session.data.Mods:
			if impMod.extras.Link in mod.extras.Link || mod.extras.Link in impMod.extras.Link:
				inst.icon = Functions.load_image(alertImg)
				inst.hint_tooltip = "Notice: A mod referencing a similar link already exists in your modlist."
		
		imports.append({
			"check":inst,
			"mod":impMod
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

func _on_SelectAllButton_pressed():
	for import in imports:
		import.check.pressed = true
	pass

func _on_DeselectAllButton_pressed():
	for import in imports:
		import.check.pressed = false
	pass
