extends Node

#--- Called by the system when the script is first loaded.
func extension_loaded():
	Globals.get_manager("console").post("Extension is loaded")
	pass

#--- Called by the system when the script is being unloaded.
func extension_unloaded():
	Globals.get_manager("console").post("Extension is unloaded")
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
		var name = mod.fields["Mods"]
		var missingReq = []
		for req in mod.extras.Required:
			if not modLinks.has(req.Link):
				missingReq.append(req)
			elif modLinks[req.Link].fields["Load Order"] >= mod.fields["Load Order"]:
				var reqName = modLinks[req.Link].fields["Mods"]
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
