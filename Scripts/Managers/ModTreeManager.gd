extends Control

const my_id = "mtree"

#-- Scene Refs
onready var mod_tree = $"../../Background/VBoxContainer/VSplitContainer/HSplitContainer/LeftContainer/ModTree"
onready var mod_popup = $"../../Popups/ModPopup"

#-- Dynamic Vars
var sortOrientation = 1
var sortCategory = ""
var modPopData
var selectedMod

func jump_start():
	var pMan = Globals.get_manager("popups")
	modPopData = pMan.get_popup_data("ModPop")
	modPopData.register_entity(my_id, self, "handle_mod_popup")
	modPopData.add_option(my_id, "Edit Mod")
	modPopData.add_separator(my_id)
	modPopData.add_option(my_id, "Copy Link")
	modPopData.add_option(my_id, "Open Link")
	modPopData.add_separator(my_id)
	modPopData.add_option(my_id, "Delete Mod")
	pass

func handle_mod_popup(selection):
	match selection:
		"Edit Mod":
			var wman = Globals.get_manager("window")
			wman.activate_window("modAdd", selectedMod.get_metadata(0))
		"Open Link":
			var data = selectedMod.get_metadata(0)
			var link = data.extras.Link
			Functions.open_link(link)
		"Copy Link":
			var data = selectedMod.get_metadata(0)
			var link = data.extras.Link
			OS.set_clipboard(link)
			Globals.get_manager("console").postwrn("Copied link to clipboard")
		"Delete Mod":
			Session.data.Mods.erase(selectedMod.get_metadata(0))
			var man = Globals.get_manager("main")
			man.repaint_mods()
	pass

#--- Draws and populates the mod tree
func draw_tree(gameData):
	mod_tree.clear()
	
	#- Create the mod tree root
	var root = mod_tree.create_item()
	
	#- Create the columns for the mod tree
	mod_tree.columns = gameData.Categories.size()
	if sortCategory == "":
		sortCategory =  gameData.Categories[0].Title
	for i in range(gameData.Categories.size()):
		create_column(i, gameData.Categories[i].Title, gameData.Categories[i].Size, (true if i == 0 else false))
	
	#- Sort modList
	var man = Globals.get_manager("main")
	var modList = man.sort_mods(sortCategory, sortOrientation)
	
	#- Create mod entries for the mod tree
	for mod in modList:
		#TODO: Add separator support.
		create_entry(mod, root, gameData)
	pass

#--- Creates a new column in the mod tree
func create_column(index:int, title:String, minWidth:int, expand:bool = false):
	mod_tree.set_column_title(index, title)
	mod_tree.set_column_min_width(index, minWidth)
	mod_tree.set_column_expand(index, expand)
	pass

#--- Creates a new separator under the root in the mod tree
func create_separator(text:String, textColor:Color, bgColor:Color, parent):
	var node = mod_tree.create_item(parent)
	node.set_text(0, text)
	node.set_selectable(0, false)
	node.set_custom_color(0, textColor)
	node.set_custom_bg_color(0, bgColor)
	return node

#--- Creates a new Mod entry for the mod tree
func create_entry(modData, parent, gameData):
	var entry = mod_tree.create_item(parent)
	entry.set_metadata(0, modData)
	for i in range(gameData.Categories.size()):
		var category = gameData.Categories[i]
		if not modData["fields"].has(category.Title):
			continue
		entry.set_text(i, modData["fields"][category.Title])
		entry.set_tooltip(i, category.Tooltip)
		entry.set_text_align(i, HALIGN_CENTER)
		entry.set_custom_color(i, modData["color"])
	return entry

#--- Opens a menu to edit the selected mod.
func _on_ModTree_item_rmb_selected(position):
	var mod = mod_tree.get_item_at_position(position)
	if mod == null:
		return
	#TODO: open popup with options.
	selectedMod = mod
	if selectedMod.get_metadata(0).extras.Link == "":
		modPopData.lock_option(my_id, "Open Link")
	else:
		modPopData.unlock_option(my_id, "Open Link")
	mod_popup.set_position(position)
	mod_popup.popup()
	pass

func _on_ModTree_column_title_pressed(column:int):
	var col = mod_tree.get_column_title(column)
	if col == sortCategory:
		sortOrientation = 0 if sortOrientation == 1 else 1
	else:
		sortOrientation = 1
	sortCategory = col
	Globals.get_manager("main").repaint_mods()
