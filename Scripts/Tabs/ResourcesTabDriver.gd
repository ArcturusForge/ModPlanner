extends ColorRect

#-- Scene Refs
onready var add_button = $VBoxContainer/HBoxContainer/AddButton
onready var new_resource_panel = $VBoxContainer/NewResourcePanel
onready var resource_name_line_edit = $VBoxContainer/NewResourcePanel/HBoxContainer/ResourceNameLineEdit
onready var resource_link_line_edit = $VBoxContainer/NewResourcePanel/HBoxContainer2/ResourceLinkLineEdit
onready var resource_tree:Tree = $VBoxContainer/HBoxContainer2/ScrollContainer/ResourceTree

#-- Resources
var copy_icon = preload("res://Assets/Graphics/32x32/(32x32)CopyIcon.png")
var open_icon = preload("res://Assets/Graphics/32x32/(32x32)OpenIcon.png")
var delete_icon = preload("res://Assets/Graphics/32x32/(32x32)DeleteIcon.png")

#-- Managers
var tab_manager

func jump_start():
	pass

func get_fresh():
	var data = []
	return data

#- Called by the system when a session has been started.
func session_launched():
	new_resource_panel.visible = false
	if not Session.data.has("Resources"):
		Session.data["Resources"] = get_fresh()
	draw_tree()
	pass

func add_resource():
	var data = {
		"Name":resource_name_line_edit.text,
		"Link":resource_link_line_edit.text
	}
	Session.data.Resources.append(data)
	Globals.get_manager("console").post("Added new resource: " + resource_name_line_edit.text)
	Globals.repaint_app_name(true)
	draw_tree()
	pass

func draw_tree():
	resource_tree.clear()
	resource_tree.set_column_expand(0, true)
	resource_tree.set_column_expand(1, false)
	resource_tree.set_column_expand(2, false)
	resource_tree.set_column_expand(3, false)
	resource_tree.set_column_min_width(1, 40)
	resource_tree.set_column_min_width(2, 40)
	resource_tree.set_column_min_width(3, 40)
	var root = resource_tree.create_item()
	for resource in Session.data.Resources:
		var node = resource_tree.create_item(root)
		node.set_text(0, " " + resource.Name)
		node.set_metadata(0, resource)
		node.set_selectable(0, false)
		node.add_button(1, open_icon)
		node.add_button(2, copy_icon)
		node.add_button(3, delete_icon)
		node.set_tooltip(1, "Open Link")
		node.set_tooltip(2, "Copy Link")
		node.set_tooltip(3, "Delete Resource")
	pass

func _on_AddButton_pressed():
	new_resource_panel.visible = true
	resource_name_line_edit.text = ""
	resource_link_line_edit.text = ""
	pass

func _on_CancelButton_pressed():
	new_resource_panel.visible = false
	pass

func _on_ConfirmButton_pressed():
	add_resource()
	new_resource_panel.visible = false
	pass

func _on_ResourceTree_button_pressed(item, column, id):
	var res = item.get_metadata(0)
	match column:
		1:
			Functions.open_link(res.Link)
			Globals.get_manager("console").generate("Opening resource link...", Globals.green)
		2:
			OS.clipboard = res.Link
			Globals.get_manager("console").postwrn("Copied resource link")
		3:
			Session.data.Resources.erase(res)
			Globals.get_manager("console").postwrn("Deleted resource link")
			Globals.repaint_app_name(true)
			draw_tree()
	pass
