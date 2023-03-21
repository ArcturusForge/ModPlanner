extends Control

#-- Assigned by system
var window_manager

#-- Managers
var mainManager

#-- Scene Refs
onready var mod_config_container = $Border2/BG/ScrollContainer/ModConfigContainer

#-- Prefabs
var one_line_field = "res://Assets/Prefabs/Fields/OneLineField.tscn"
var integer_field = "res://Assets/Prefabs/Fields/IntegerField.tscn"

#-- Dynamic Vars
var fields = []

#--- Called when the window is added to the scene.
func _create():
	mainManager = Globals.get_manager("main")
	pass

#--- Called when the window is activated.
func _enable():
	generate_window()
	pass

#--- Called when the window is deactivated.
func _disable():
	fields.clear()
	for child in mod_config_container.get_children():
		child.queue_free()
	pass

#--- Called when the window is removed from the scene.
func _destroy():
	pass

func generate_window():
	var activeGame = mainManager.activeGame
	var previousField = null
	for category in activeGame.Categories:
		#- Match the field's type to a prefab
		var inst
		match category.Field.to_lower():
			"string":
				inst = Functions.get_from_prefab(one_line_field)
			"integer":
				inst = Functions.get_from_prefab(integer_field)
			"select":
				#TODO: Read from choice array in game data.
				continue
		
		#- Safety check
		if inst == null:
			continue
		
		#- Instantiate new field and cache
		mod_config_container.add_child(inst)
		fields.append(inst)
		
		#- Wait a frame for the current field's scene refs to connect
		yield(get_tree().create_timer(0.001), "timeout")
		
		#- Link the previous field to the current one
		if not previousField == null:
			previousField.nextField = inst
		
		#- Configure the current field
		previousField = inst
		inst.set_label(category.Prompt)
		inst.fieldData = category
	
	#TODO: Generate extra's fields
	
	
	#- Set focus to the first field
	fields[0].set_focus()
	previousField.nextField = self
	pass

func _on_AddButton_pressed():
	var modData = Globals.modData.new()
	for field in fields:
		modData.add_field(field.fieldData.Title, field.get_value())
	mainManager.add_mod(modData.extract())
	window_manager.disable_window()
	pass

func _on_CancelButton_pressed():
	window_manager.disable_window()
	pass

#--- Called by the last input field. Named this way on purpose.
func set_focus():
	_on_AddButton_pressed()
	pass
