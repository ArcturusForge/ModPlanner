extends Node

var errors = []

#--- Creates an missing_master error.
func add_required_error(mod, req):
	errors.append({
		"Link":req.Link,
		"Message":"ERR404: Missing a master file for " + mod + " mod. Missing master is: " + req.Name
	})
	pass

#--- Creates a patchable_incompatibility error.
func add_patchable_error(mod, inc):
	errors.append({
		"Link":inc.Patch,
		"Message":"ERR420: Incompatible mods without required patch detected! " + mod + " & " + inc.Name
	})
	pass

#--- Creates an unpatchable_incompatibility error.
func add_unpatchable_error(mod, inc):
	errors.append({
		"Link":"",
		"Message":"ERR626: Incompatible mods with no patch detected! " + mod + " & " + inc.Name
	})
	pass

#--- Posts the scan results to the user console.
func post_result(withLinks=true):
	if errors.size() > 0:
		for err in errors:
			var message = err.Message
			if not err.Link == "" && withLinks:
				message += " [/color][color="+Globals.yellow+"][url=" + err.Link + "]Open Mod Page[/url]"
			Globals.get_manager("console").posterr(message)
	else:
		Globals.get_manager("console").post("Scan complete.\nNo issues detected!")
	pass

#--- Searches the detected errors for any with links.
func has_links():
	if errors.size() > 0:
		for error in errors:
			if error.Link == "":
				continue
			else:
				return true
	return false

#--- Compiles the error links into one array without the duplicating links.
func compile_links():
	var compLinks = []
	for error in errors:
		if error.Link == "" || compLinks.has(error.Link):
			continue
		else:
			compLinks.append(error.Link)
	return compLinks
