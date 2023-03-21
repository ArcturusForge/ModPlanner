extends Control

onready var mod_tree = $"../../Background/VBoxContainer/VSplitContainer/HSplitContainer/LeftContainer/ModTree"

#--- Draws and populates the mod tree
func draw_tree(gameData, modList):
	mod_tree.clear()
	
	#- Create the mod tree root
	var root = mod_tree.create_item()
	
	#- Create the columns for the mod tree
	mod_tree.columns = gameData.Categories.size()
	for i in range(gameData.Categories.size()):
		create_column(i, gameData.Categories[i].Title, gameData.Categories[i].Size, (true if i == 0 else false))
	
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

#--- Creates a new Header under the root in the mod tree
func create_header(text:String, textColor:Color, bgColor:Color, parent):
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
