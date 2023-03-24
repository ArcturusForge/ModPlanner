extends Node

var errors = []

#--- Returns the amount of errors
func size():
	return errors.size()

#--- Creates an missing_master error.
func add_required_error(mod, req, type=2):
	errors.append({
		"Type":type,
		"Link":req.Link,
		"Message":"ERR404: Missing a master file for [" + mod + "] mod. Missing master is: " + req.Name
	})
	pass

#--- Creates a patchable_incompatibility error.
func add_patchable_error(mod, inc, type=1):
	errors.append({
		"Type":type,
		"Link":inc.Patch,
		"Message":"ERR420: Incompatible mods without required patch detected! [" + mod + "] and [" + inc.Name + "]"
	})
	pass

#--- Creates an unpatchable_incompatibility error.
func add_unpatchable_error(mod, inc, type=2):
	errors.append({
		"Type":type,
		"Link":"",
		"Message":"ERR626: Unpatchable mod conflict detected! [" + mod + "] & [" + inc.Name + "]"
	})
	pass

func add_custom(msg, type=1, link = ""):
	errors.append({
		"Type":type,
		"Link":link,
		"Message":msg
	})
	pass

#--- Posts the scan results to the user console.
func post_result(withLinks=true):
	if errors.size() > 0:
		for err in errors:
			#- Create an artificial delay to not overwhelm user.
			yield(Globals.get_tree().create_timer(0.25), "timeout")
			
			var message = err.Message
			if not err.Link == "" && withLinks:
				message += " [/color][color="+Globals.blue+"][url=" + err.Link + "]Open Mod Page[/url]"
			
			if err.Type == 2:
				Globals.get_manager("console").posterr(message)
			elif err.Type == 1:
				Globals.get_manager("console").postwrn(message)
			elif err.Type == 0:
				Globals.get_manager("console").post(message)
		
		Globals.get_manager("console").post("Scan complete.")
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
