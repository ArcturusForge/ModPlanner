extends Control

#-- Assigned by system
var window_manager

#-- Managers
var mainManager

#-- Scene Refs
onready var mod_config_container = $Border2/BG/ScrollContainer/ModConfigContainer
onready var req_container = $Border2/BG/ScrollContainer2/ModConfigContainer/ModExtrasField/RequiredModsList/ReqContainer
onready var inc_container = $Border2/BG/ScrollContainer2/ModConfigContainer/ModExtrasField/IncompatibleModsList/IncompatibleContainer
onready var mod_link_text = $Border2/BG/ScrollContainer2/ModConfigContainer/ModExtrasField/ModLinkText
onready var confirm_button = $Border2/BG/ConfirmButton

#-- Prefabs
var one_line_field = "res://Assets/Prefabs/Fields/Modular/OneLineField.tscn"
var integer_field = "res://Assets/Prefabs/Fields/Modular/IntegerField.tscn"
var selector_field = "res://Assets/Prefabs/Fields/Modular/SelectorField.tscn"
var incom_mod = "res://Assets/Prefabs/Fields/Extras/IncompatibleMod.tscn"
var requi_mod = "res://Assets/Prefabs/Fields/Extras/RequiredMod.tscn"

#-- Dynamic Vars
var modIndex
var fields = []
var required = []
var incompatible = []

#--- Called when the window is added to the scene.
func _create():
	mainManager = Globals.get_manager("main")
	pass

#--- Called when the window is activated.
func _enable(_data):
	generate_window(_data)
	pass

#--- Called when the window is deactivated.
func _disable():
	fields.clear()
	required.clear()
	incompatible.clear()
	modIndex = null
	for child in mod_config_container.get_children():
		child.queue_free()
	for child in req_container.get_children():
		child.queue_free()
	for child in inc_container.get_children():
		child.queue_free()
	pass

#--- Called when the window is removed from the scene.
func _destroy():
	pass

func generate_window(modData):
	var activeGame = mainManager.activeGame
	var previousField = null
	
	if not modData == null:
		confirm_button.connect("pressed", self, "_on_edit_mod")
	else:
		confirm_button.connect("pressed", self, "_on_add_mod")
	
	for category in activeGame.data.Categories:
		#- Match the field's type to a prefab
		var inst
		var dynamicData = {}
		if not modData == null:
			modIndex = modData.index
			dynamicData["info"] = modData.fields[category.Title]
		
		match category.Field.to_lower():
			"string":
				inst = Functions.get_from_prefab(one_line_field)
			"integer":
				inst = Functions.get_from_prefab(integer_field)
			"select":
				inst = Functions.get_from_prefab(selector_field)
				
				#- Read from choice array in game data.
				dynamicData["selector"] = []
				for option in category.Select:
					dynamicData["selector"].append(option)
		
		#- Safety check
		if inst == null:
			continue
		
		#- Instantiate new field and cache
		mod_config_container.add_child(inst)
		fields.append(inst)
		
		#- Wait a frame for the current field's scene refs to connect
		Functions.wait_frame()
		
		#- Link the previous field to the current one
		if not previousField == null:
			previousField.nextField = inst
		
		#- Configure the current field
		previousField = inst
		inst.set_data(category.Prompt, dynamicData)
		inst.fieldData = category
	
	#TODO: Get the extra's data from mod data if != null
	if not modData == null:
		mod_link_text.text = modData.extras.Link
		for req in modData.extras.Required:
			self._on_AddReqButton_pressed(req)
		for inc in modData.extras.Incompatible:
			self._on_AddIncButton_pressed(inc)
	
	#- Set focus to the first field
	fields[0].set_focus()
	previousField.nextField = self
	pass

func _on_add_mod():
	confirm_button.disconnect("pressed", self, "_on_add_mod")
	var modData = Globals.modData.new()
	modData.extras.Link = mod_link_text.text
	for field in fields:
		modData.add_field(field.fieldData.Title, field.get_value())
	for req in required:
		modData.add_required(req.get_data())
	for inc in incompatible:
		modData.add_incompatible(inc.get_data())
	mainManager.add_mod(modData.extract())
	window_manager.disable_window()
	pass

func _on_edit_mod():
	confirm_button.disconnect("pressed", self, "_on_edit_mod")
	var modData = Globals.modData.new()
	for field in fields:
		modData.add_field(field.fieldData.Title, field.get_value())
	for req in required:
		modData.add_required(req.get_data())
	for inc in incompatible:
		modData.add_incompatible(inc.get_data())
	mainManager.edit_mod(modData.extract(), modIndex)
	window_manager.disable_window()
	pass

func _on_CancelButton_pressed():
	window_manager.disable_window()
	var conns = confirm_button.get_signal_connection_list("pressed")
	for conn in conns:
		confirm_button.disconnect(conn.signal, conn.target, conn.method)
	pass

#--- Called by the last modular input field. Named this way on purpose.
func set_focus():
	mod_link_text.grab_focus()
	pass

#--- Creates a new required mod field.
func _on_AddReqButton_pressed(reqData = null):
	var inst = Functions.get_from_prefab(requi_mod)
	req_container.add_child(inst)
	Functions.wait_frame()
	inst.construct(self, required.size(), reqData)
	required.append(inst)
	pass

#--- Creates a new incompatible mod field.
func _on_AddIncButton_pressed(incData = null):
	var inst = Functions.get_from_prefab(incom_mod)
	inc_container.add_child(inst)
	Functions.wait_frame()
	inst.construct(self, incompatible.size(), incData)
	incompatible.append(inst)
	pass

#--- Removes a required mod from the tracked list.
func remove_required(listIndex):
	required.remove(listIndex)
	if not required.size() > 0:
		return
	for i in range(listIndex, required.size()):
		required[i].drop_index()
	pass

#--- Removes a incompatible mod from the tracked list.
func remove_incompatible(listIndex):
	incompatible.remove(listIndex)
	if not incompatible.size() > 0:
		return
	for i in range(listIndex, incompatible.size()):
		incompatible[i].drop_index()
	pass