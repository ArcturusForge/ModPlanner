extends Node

#--- Called by the system to scan for mod compatibility
func scan_mods(modlist):
	var scanData = Globals.scanData.new()
	#- Return the scan results so the system can parse them.
	return scanData

#--- Called by the system to sort the mod tree.
#- orientation: 0 = descending, 1 = ascending
func sort_mod_list(category, orientation, modlist):
	var copy = modlist.duplicate()
	return copy
