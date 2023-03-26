extends Node

var color = Globals.grey
var fields = {}
var extras = {
	"Link":"",
	"Required":[],
	"Compatible":[],
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

func add_required(data):
	extras.Required.append(data)
	pass

func add_compatible(data):
	extras.Compatible.append(data)
	pass

func add_incompatible(data):
	extras.Incompatible.append(data)
	pass
