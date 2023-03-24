extends Node

const my_id = "skyrimExtension"

#--- Called by the system when the script is first loaded.
func extension_loaded():
	var extensionMenu = Globals.get_manager("popups").get_popup_data("ExtenMenu")
	extensionMenu.register_entity(my_id, self, "handle_extension_menu")
	extensionMenu.add_option(my_id, "Auto Assign Load Order")
	pass

func handle_extension_menu(selection):
	match selection:
		"Auto Assign Load Order":
			Globals.get_manager("console").generate("Assigning load orders...", Globals.green)
			sort_l_o()
	pass

func sort_l_o():
	#- Store any errors in scanData.
	var scanData = Globals.scanData.new()
	#- Grab the mod list from the current session.
	#- DO NOT APPLY DIRECTLY TO SESSION MODLIST!!!!
	var modlist = Session.data.Mods.duplicate()
	var modLinks = {}
	for mod in modlist:
		modLinks[mod.extras.Link] = {
			"mod":mod,
			"weight":1
		}
	
	# Idea:
	# Sort through all mods by how many requirements they have.
	# After that, start with the mod with most requirements and work down to least,
	# adding weight to each required mod.
	modlist.sort_custom(self, "required_sort")
	for sorted in modlist:
		for req in sorted.extras.Required:
			if modLinks.has(req.Link):
				modLinks[req.Link].weight += modLinks[sorted.extras.Link].weight
			else:
				scanData.add_custom("Missing Masters Detected! Run a modlist scan!", 2)
		
		for inc in sorted.extras.Incompatible:
			if modLinks.has(inc.Link):
				if not inc.Patchable:
					scanData.add_custom("Incompatible Mods Detected! Run a modlist scan!", 2)
				else:
					if not modLinks.has(inc.Patch):
						scanData.add_custom("Unpatched Mods Detected! Run a modlist scan!", 1)
	
	#- Loop through the weighted mods and order them from 0 up.
	var weightedList = modLinks.values()
	weightedList.sort_custom(self, "weighted_sort")
	for i in range(weightedList.size()):
		var mod = weightedList[i].mod
		mod.fields["Load Order"] = str(i)
	
	#- Apply changes to Session
	var mainMan = Globals.get_manager("main")
	for mod in modlist:
		mainMan.edit_mod(mod, mod.index)
	
	scanData.add_custom("Auto Sort Completed.", 0)
	scanData.post_result()
	pass

#--- Sort by number of required mods
func required_sort(mod_a, mod_b):
	var a = mod_a.extras.Required.size()
	var b = mod_b.extras.Required.size()
	if a > b:
		return true
	return false

func weighted_sort(weight_a, weight_b):
	var a = weight_a.weight
	var b = weight_b.weight
	if a > b:
		return true
	return false

#--- Called by the system when the script is being unloaded.
func extension_unloaded():
	Globals.get_manager("popups").get_popup_data("ExtenMenu").unregister_entity(my_id)
	pass

#--- Called by the system to access a mod's name.
func get_mod_name(mod):
	return mod.fields.Mods

#--- Called by the system to scan for mod compatibility.
func scan_mods(modlist):
	var scanData = Globals.scanData.new()
	var modLinks = {}
	for mod in modlist:
		modLinks[mod.extras.Link] = mod
	
	for mod in modlist:
		var name = get_mod_name(mod)
		var missingReq = []
		for req in mod.extras.Required:
			if not modLinks.has(req.Link):
				missingReq.append(req)
			elif modLinks[req.Link].fields["Load Order"] >= mod.fields["Load Order"]:
				var reqName = get_mod_name(modLinks[req.Link])
				var msg = "ERR314: [" + name + "] requires [" + reqName + "] as a master however [" + reqName + "] has a higher load order!"
				scanData.add_custom(msg)
		
		for inc in mod.extras.Incompatible:
			if modLinks.has(inc.Link):
				if inc.Patchable:
					if modLinks.has(inc.Patch):
						continue
					else:
						scanData.add_patchable_error(name, inc)
				else:
					scanData.add_unpatchable_error(name, inc)
		
		if missingReq.size() > 0:
			for i in range(missingReq.size()):
				scanData.add_required_error(name, missingReq[i])
	
	#- Return the scan results so the system can parse them.
	if scanData.size() > 0:
		scanData.add_custom("Scan Complete.", 0)
	return scanData

#--- Called by the system to sort the mod tree.
#- orientation: 0 = descending, 1 = ascending.
func sort_mod_list(category, orientation, modlist:Array):
	var copy = modlist.duplicate()
	match category:
		"Mods":
			if orientation == 0:
				copy.sort_custom(self, "s_m_d")
			elif orientation == 1:
				copy.sort_custom(self, "s_m_a")
		"Type":
			if orientation == 0:
				copy.sort_custom(self, "s_t_d")
			elif orientation == 1:
				copy.sort_custom(self, "s_t_a")
		"Version":
			if orientation == 0:
				copy.sort_custom(self, "s_v_d")
			elif orientation == 1:
				copy.sort_custom(self, "s_v_a")
		"Source":
			if orientation == 0:
				copy.sort_custom(self, "s_s_d")
			elif orientation == 1:
				copy.sort_custom(self, "s_s_a")
		"Priority Order":
			if orientation == 0:
				copy.sort_custom(self, "s_p_d")
			elif orientation == 1:
				copy.sort_custom(self, "s_p_a")
		"Load Order":
			if orientation == 0:
				copy.sort_custom(self, "s_l_d")
			elif orientation == 1:
				copy.sort_custom(self, "s_l_a")
	return copy

func sort_desc(mod_a, mod_b, field):
	var a = mod_a.fields[field]
	var b = mod_b.fields[field]
	if a > b:
		return true
	return false

func sort_asce(mod_a, mod_b, field):
	var a = mod_a.fields[field]
	var b = mod_b.fields[field]
	if a < b:
		return true
	return false

func s_m_d(mod_a, mod_b):
	return sort_desc(mod_a, mod_b, "Mods")

func s_m_a(mod_a, mod_b):
	return sort_asce(mod_a, mod_b, "Mods")

func s_t_d(mod_a, mod_b):
	return sort_desc(mod_a, mod_b, "Type")

func s_t_a(mod_a, mod_b):
	return sort_asce(mod_a, mod_b, "Type")

func s_v_d(mod_a, mod_b):
	return sort_desc(mod_a, mod_b, "Version")

func s_v_a(mod_a, mod_b):
	return sort_asce(mod_a, mod_b, "Version")

func s_s_d(mod_a, mod_b):
	return sort_desc(mod_a, mod_b, "Source")

func s_s_a(mod_a, mod_b):
	return sort_asce(mod_a, mod_b, "Source")

func s_p_d(mod_a, mod_b):
	return sort_desc(mod_a, mod_b, "Priority Order")

func s_p_a(mod_a, mod_b):
	return sort_asce(mod_a, mod_b, "Priority Order")

func s_l_d(mod_a, mod_b):
	return sort_desc(mod_a, mod_b, "Load Order")

func s_l_a(mod_a, mod_b):
	return sort_asce(mod_a, mod_b, "Load Order")
