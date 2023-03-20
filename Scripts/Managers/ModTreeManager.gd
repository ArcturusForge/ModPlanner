extends Control

onready var mod_tree = $"../../Background/VBoxContainer/VSplitContainer/HSplitContainer/LeftContainer/ModTree"

#-- Default Colors
var clear = Color(0, 0, 0, 0)
var grey = Color("b2b5bb")

#--- Draws and populates the mod tree
func draw_tree(columnData, modList):
	mod_tree.clear()
	
	#- Create the mod tree root
	var root = mod_tree.create_item()
	
	#- Create the columns for the mod tree
	mod_tree.columns = columnData.size()
	for i in range(columnData.size()):
		create_column(i, columnData[i].get_title(), columnData[i].get_width(), (true if i == 0 else false))
	
	#- Create mod entries for the mod tree
	for mod in modList:
		#TODO: Add separator support.
		create_entry(mod, root, columnData)
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
func create_entry(modData, parent, columnData):
	var entry = mod_tree.create_item(parent)
	for i in range(columnData.size()):
		var categoryTitle = columnData[i].get_title()
		entry.set_text(i, modData["fields"][categoryTitle])
		entry.set_text_align(i, HALIGN_CENTER)
		entry.set_custom_color(i, modData["color"])
	return entry
