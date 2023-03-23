extends Node

var sessionName: String
var data = {}

#-- Local Cache - Stored only during session and not saved.
var savePath := ""

func reset_data():
	savePath = ""
	sessionName = Globals.sessionNameDefault
	data = {}
	pass

func has_saved():
	return true if not savePath == "" else false

func quick_save():
	save_data(savePath)
	pass

#--- Makes a copy of the session but doesn't make it the active session.
func export_save(path:String):
	if not Globals.saveExtension in sessionName:
		sessionName += "." + Globals.saveExtension
	
	var compilation = {
		"data" : data
	}
	print (path)
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(to_json(compilation))
	file.close()
	
	Globals.repaint_app_name()
	pass

#--- Makes a copy of the session and makes it the active session.
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
	Globals.repaint_app_name()
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
