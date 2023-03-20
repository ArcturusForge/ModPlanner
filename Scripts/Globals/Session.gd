extends Node

var sessionName: String
var data = {}

# Local Cache - Stored only during session and not saved.
var savePath := ""

func reset_data():
	savePath = ""
	sessionName = Globals.sessionNameDefault
	data = {}
	pass

func quick_save():
	save_data(savePath)
	pass

func save_data(path: String):
	if not Globals.saveExtension in sessionName:
		sessionName += "." + Globals.saveExtension
	
	if not sessionName in path:
		path += "/" + sessionName
	
	var compilation = {
		"data" : data
	}
	print (path)
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(to_json(compilation))
	file.close()
	
	savePath = path
	Functions.set_app_name()
	pass

func load_data(path: String):
	var file = File.new()
	file.open(path, File.READ)
	var text = file.get_as_text()
	file.close()
	
	var compilation = parse_json(text)
	data = compilation.data
	sessionName = path.get_file()
	savePath = path
	pass
