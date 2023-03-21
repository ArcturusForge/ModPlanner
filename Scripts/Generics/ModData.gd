extends Node

var color = Globals.grey
var fields = {}
var extras = {
	"Link":"",
	"Required":[],
	"Incompatible":[]
}

func extract():
	var data = {
		"color":color,
		"fields":fields,
		"extras":extras
	}
	return data

func add_field(label, value):
	fields[label] = value
	pass
 
func add_link(url):
	extras.Link = url
	pass

func add_required(name, url):
	extras.Required.append({
		"Name":name,
		"Link":url
	})
	pass

func add_incompatible(name, url, patch_url = "", patchable = false):
	extras.Incompatible.append({
		"Patchable":patchable,
		"Name":name,
		"Link":url,
		"Patch":patch_url
	})
	pass
