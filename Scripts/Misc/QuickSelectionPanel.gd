extends ColorRect

onready var tree = $Bg/VBoxContainer/ScrollContainer/Tree

signal on_selected
var selectedMod

func open_selector(modlist=[], excludeList=[]):
	var drawList = []
	for mod in modlist:
		if not excludeList.has(mod.extras.Link):
			drawList.append(mod)
	var root = tree.create_item()
	var mana = Globals.get_manager("main")
	for mod in drawList:
		var node = tree.create_item(root)
		var data = {
			"Name":mana.get_mod_name(mod),
			"Link":mod.extras.Link
		}
		node.set_metadata(0, data)
		node.set_text(0, mana.get_mod_name(mod))
	self.visible = true
	pass

func close_selector():
	var connections = self.get_signal_connection_list("on_selected")
	for conn in connections:
		self.disconnect(conn.signal, conn.target, conn.method)
	
	tree.clear()
	selectedMod = null
	self.visible = false
	pass

func _on_CloseButton_pressed():
	close_selector()
	pass


func _on_SelectButton_pressed():
	self.emit_signal("on_selected", selectedMod)
	close_selector()
	pass


func _on_Tree_item_selected():
	selectedMod = tree.get_selected().get_metadata(0)
	pass


func _on_Tree_item_activated():
	selectedMod = tree.get_selected().get_metadata(0)
	self.emit_signal("on_selected", selectedMod)
	close_selector()
	pass
