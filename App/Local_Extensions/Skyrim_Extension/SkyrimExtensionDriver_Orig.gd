extends Node

const my_id = "skyrimExtension"

#--- Called by the system when the script is first loaded.
func extension_loaded():
	var extensionMenu = Globals.get_manager("popups").get_popup_data("ExtenMenu")
	extensionMenu.register_entity(my_id, self, "handle_extension_menu")
	extensionMenu.add_option(my_id, "Auto Sort Order")
	pass

func handle_extension_menu(selection):
	match selection:
		"Auto Sort Order":
			Globals.get_manager("console").generate("Assigning load orders...", Globals.green)
			sort_l_o()
	pass

func sort_l_o():
	#- Store any errors in scanData.
	var scanData = Globals.scanData.new()
	
	#- Grab the mod list from the current session.
	var modlist = Session.data.Mods
	var modLinks = {}
	var plugFreeTotal = 0
	var enginePlugTotal = 0
	for mod in modlist:
		if mod.fields.Type == "Plugin-free":
			plugFreeTotal += 1
		elif mod.fields.Type == "Engine Plugin":
			enginePlugTotal += 1
		
		var startingVal = 1 if not mod.fields.Type == "Overwrite-able Fix" else 1000
		modLinks[mod.extras.Link] = {
			"mod":mod,
			"pass1":startingVal,
			"pass2":1
		}
	
	#- First Pass: 
	#- Sort through all mods by how many requirements they have.
	#- After that, start with the mod with most requirements and work down to least,
	#- adding weight to each required mod.
	modlist.sort_custom(self, "required_sort_pass1")
	for sorted in modlist:
		for req in sorted.extras.Required:
			if modLinks.has(req.Link):
				modLinks[req.Link].pass1 += modLinks[sorted.extras.Link].pass1
			else:
				scanData.add_custom("Missing Masters Detected! Run a modlist scan!", 2)
		
		if sorted.extras.has("Compatible"):
			for com in sorted.extras.Compatible:
				if modLinks.has(com.Link):
					if com.Overwrite == "Do Overwrite" && modLinks[com.Link].pass1 > modLinks[sorted.extras.Link].pass1:
						print("Yolo")
		
		for inc in sorted.extras.Incompatible:
			if modLinks.has(inc.Link):
				if not inc.Patchable:
					scanData.add_custom("Incompatible Mods Detected! Run a modlist scan!", 2)
				else:
					if not modLinks.has(inc.Patch):
						scanData.add_custom("Unpatched Mods Detected! Run a modlist scan!", 1)
	
	#- Second Pass:
	#- Invert the order and run through the list again.
	modlist.sort_custom(self, "required_sort_pass2")
	for sorted in modlist:
		for req in sorted.extras.Required:
			if modLinks.has(req.Link):
				modLinks[req.Link].pass2 += modLinks[sorted.extras.Link].pass1
	
	#- Loop through the weighted mods and order them from 0 up.
	var weightedList = modLinks.values()
	weightedList.sort_custom(self, "weighted_sort")
	var loadIndex = 0
	var prioIndex = 0
	var enplugIndex = 0
	for weight in weightedList:
		var mod = weight.mod
		if mod.fields["Type"] == "Engine Extender":
			mod.fields["Load Order"] = str(-1)
			mod.fields["Priority Order"] = str(-1)
			
		elif mod.fields["Type"] == "Engine Plugin":
			mod.fields["Load Order"] = str(-1)
			mod.fields["Priority Order"] = str(enplugIndex)
			enplugIndex+=1
			
		elif mod.fields["Type"] == "Plugin-free":
			mod.fields["Load Order"] = str(-1)
			mod.fields["Priority Order"] = str(prioIndex + enginePlugTotal)
			prioIndex+=1
			
		else:
			mod.fields["Load Order"] = str(loadIndex)
			mod.fields["Priority Order"] = str(prioIndex + enginePlugTotal)
			loadIndex+=1
			prioIndex+=1
	
	Globals.get_manager("main").repaint_mods()
	Globals.repaint_app_name(true)
	scanData.closing_msg = "Auto Sort Completed."
	scanData.post_result()
	pass

#--- Sort by number of required mods
func required_sort_pass1(mod_a, mod_b):
	var a = mod_a.extras.Required.size()
	var b = mod_b.extras.Required.size()
	if a > b:
		return true
	return false

func required_sort_pass2(mod_a, mod_b):
	var a = mod_a.extras.Required.size()
	var b = mod_b.extras.Required.size()
	if a < b:
		return true
	return false

func weighted_sort(weight_a, weight_b):
	var a = weight_a.pass1 + weight_a.pass2
	var b = weight_b.pass1 + weight_b.pass2
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
			else:
				var reqMod = modLinks[req.Link]
				
				if mod.fields["Type"] == "Plugin-free":
					if	int(reqMod.fields["Priority Order"]) >= int(mod.fields["Priority Order"]):
						var reqName = get_mod_name(reqMod)
						var msg = "ERR117: [" + name + "] overwrites files from [" + reqName + "] however [" + reqName + "] is overwriting its files!"
						scanData.add_custom(msg, 2)
				
				elif mod.fields["Type"] == "Engine Plugin":
					if	int(reqMod.fields["Priority Order"]) >= int(mod.fields["Priority Order"]):
						var reqName = get_mod_name(reqMod)
						var msg = "ERR66: ["+ name +"] relies on features from ["+ reqName +"] however ["+ reqName +"] has a higher priority order. Fix this if bugs occur in-game."
						scanData.add_custom(msg, 1)
				
				elif int(reqMod.fields["Load Order"]) >= int(mod.fields["Load Order"]):
					var reqName = get_mod_name(reqMod)
					var msg = "ERR314: [" + name + "] requires [" + reqName + "] as a master however [" + reqName + "] has a higher load order!"
					scanData.add_custom(msg, 2)
		
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

func sort_desc(mod_a, mod_b, field, isString = true):
	var a = mod_a.fields[field] if isString == true else int(mod_a.fields[field])
	var b = mod_b.fields[field] if isString == true else int(mod_b.fields[field])
	if a > b:
		return true
	return false

func sort_asce(mod_a, mod_b, field, isString = true):
	var a = mod_a.fields[field] if isString == true else int(mod_a.fields[field])
	var b = mod_b.fields[field] if isString == true else int(mod_b.fields[field])
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
	return sort_desc(mod_a, mod_b, "Priority Order", false)

func s_p_a(mod_a, mod_b):
	return sort_asce(mod_a, mod_b, "Priority Order", false)

func s_l_d(mod_a, mod_b):
	return sort_desc(mod_a, mod_b, "Load Order", false)

func s_l_a(mod_a, mod_b):
	return sort_asce(mod_a, mod_b, "Load Order", false)
