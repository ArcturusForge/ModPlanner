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
	var presentMods = {}
	var allAdd = []
	var enginePlugTotal = 0
	for mod in modlist:
		if mod.fields.Type == "Engine Plugin":
			enginePlugTotal += 1
		elif mod.fields.Type == "Overwrite-able Replacer" || mod.fields.Type == "Overwrite-able Fix":
			allAdd.append(mod.extras.Link)
		
		presentMods[mod.extras.Link] = {
			"mod":mod,
			"influence":modlist.size(),
			"masters":[]
		}
		continue
	
	for mod in modlist:
		var requisiteMods = []
		for req in mod.extras.Required:
			if presentMods.has(req.Link):
				requisiteMods.append(presentMods[req.Link])
			else:
				scanData.add_custom("Missing Masters Detected!! Run a scan for more details.", 2)
			continue
		
		if mod.extras.has("Compatible"):
			for com in mod.extras.Compatible:
				if presentMods.has(com.Link):
					requisiteMods.append(presentMods[com.Link])
		
		if not allAdd.has(mod.extras.Link):
			for addlink in allAdd:
				requisiteMods.append(presentMods[addlink])
		
		presentMods[mod.extras.Link].masters = requisiteMods
		continue
	
	for mod in presentMods.keys():
		var mData = presentMods[mod]
		mData.influence += -1
		increment_masters(presentMods, mData)
		continue
	
	var influnceList = presentMods.values().duplicate()
	influnceList.sort_custom(self, "sort_by_influence")
	var lo = 0
	var po = 0
	var epo = enginePlugTotal + 1
	for sorted in influnceList:
		if sorted.mod.fields["Type"] == "Engine Extender":
			sorted.mod.fields["Load Order"] = str(-1)
			sorted.mod.fields["Priority Order"] = str(-1)
		elif sorted.mod.fields["Type"] == "Engine Plugin" || sorted.mod.fields["Type"] == "Plugin-free":
			sorted.mod.fields["Load Order"] = str(-1)
			sorted.mod.fields["Priority Order"] = str(po)
			po += 1
		elif sorted.mod.fields["Type"] == "Overwrite-able Replacer":
			sorted.mod.fields["Load Order"] = str(-1)
			sorted.mod.fields["Priority Order"] = str(epo)
			epo += 1
		else:
			sorted.mod.fields["Load Order"] = str(lo)
			sorted.mod.fields["Priority Order"] = str(epo)
			lo += 1
			epo += 1
		continue
	
	Globals.get_manager("main").repaint_mods()
	Globals.repaint_app_name(true)
	scanData.closing_msg = "Auto Sort Completed."
	scanData.post_result()
	pass

func increment_masters(presentMods, mData):
	for data in mData.masters:
		var masterDat = presentMods[data.mod.extras.Link]
		masterDat.influence += (mData.influence - 1)
		increment_masters(presentMods, masterDat)
	pass

func sort_by_influence(mData1, mData2):
	var a = mData1.influence
	var b = mData2.influence
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
						var msg = "ERR117: (" + name + ") overwrites files from (" + reqName + ") however (" + reqName + ") is overwriting its files!"
						scanData.add_custom(msg, 2)
				
				elif mod.fields["Type"] == "Engine Plugin":
					if	int(reqMod.fields["Priority Order"]) >= int(mod.fields["Priority Order"]):
						var reqName = get_mod_name(reqMod)
						var msg = "ERR66: ("+ name +") relies on features from ("+ reqName +") however ("+ reqName +") has a higher priority order. Fix this if bugs occur in-game."
						scanData.add_custom(msg, 1)
				
				elif int(reqMod.fields["Load Order"]) >= int(mod.fields["Load Order"]):
					var reqName = get_mod_name(reqMod)
					var msg = "ERR314: (" + name + ") requires (" + reqName + ") as a master however (" + reqName + ") has a higher load order!"
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
		if mod.extras.has("Compatible"):
			for com in mod.extras.Compatible:
				if modLinks.has(com.Link):
					var orderToCheck = "Load"
					if mod.fields["Type"] == "Plugin-free" || mod.fields["Type"] == "Engine Extender" || mod.fields["Type"] == "Engine Plugin" || mod.fields["Type"] == "Overwrite-able Replacer":
						orderToCheck = "Priority"
					var comName = get_mod_name(modLinks[com.Link])
					if "Do" in com.Overwrite && int(modLinks[com.Link].fields[orderToCheck+" Order"]) > int(mod.fields[orderToCheck+" Order"]):
						scanData.add_custom("Notice: (" + name + ") is compatible with (" + comName + ") however ("+ name + ") should have a higher "+ orderToCheck +" Order. E.g. No--> 0-25 <--Yes")
					elif "Get" in com.Overwrite && int(modLinks[com.Link].fields[orderToCheck+" Order"]) < int(mod.fields[orderToCheck+" Order"]):
						scanData.add_custom("Notice: (" + name + ") is compatible with (" + comName + ") however ("+ comName + ") should have a higher "+ orderToCheck +" Order. E.g. No--> 0-25 <--Yes")
		
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
