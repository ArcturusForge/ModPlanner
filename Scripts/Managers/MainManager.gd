extends Control

#-- Constants
const my_id = "main"

#-- Scene Refs
onready var mod_tree_manager = $Managers/ModTreeManager
onready var popup_manager = $Managers/PopupManager
onready var window_manager = $Managers/WindowManager
onready var search_manager = $Managers/SearchManager
onready var console_manager = $Managers/ConsoleManager

#-- Dynamic Vals
var scanData
var managedGames = []
var activeGame = {
	"script":null,
	"data":null
}

func _ready():
	wipe_slate()
	Globals.repaint_app_name()
	Globals.set_manager(my_id, self)
	
	#- Read from the game extensions folder to get a list of the supported games.
	var gameExtensions = Functions.get_all_files(Globals.userDataPath + Globals.gameExtenDir, Globals.gameExtension)
	gameExtensions = Functions.get_all_files(Globals.localExtenPath, Globals.gameExtension, true, gameExtensions)
	for extension in gameExtensions:
		var game = Globals.managedGameScript.new()
		game.construct(extension)
		managedGames.append(game)
	
	#- Init the sub-managers
	popup_manager.jump_start()
	search_manager.jump_start()
	console_manager.jump_start()
	mod_tree_manager.jump_start()
	
	#- Must always be bottom of manager execution order
	window_manager.jump_start()
	
	#- Activate the starter selector
	window_manager.activate_window("openSelect")
	assign_options()
	pass

#--- Starts a fresh session
func start_new_session(extensionPath:String):
	wipe_slate(true)
	read_game_extension(extensionPath)
	repaint_mods()
	console_manager.post("Started New Session")
	Globals.repaint_app_name()
	
	#TEMP:
#	add_mod(Globals.exampleMod1)
#	add_mod(Globals.exampleMod2)
#	add_mod(Globals.exampleMod3)
#	add_mod(Globals.exampleMod4)
	pass

#--- Loads an existing session
func open_loaded_session(filePath:String):
	wipe_slate(true)
	Session.load_data(filePath)
	var found = false
	for game in managedGames:
		if game.gameName == Session.data["Game"]:
			found = true
			read_game_extension(game.filePath)
			break
	
	if not found:
		console_manager.posterr("ERR1001: Cannot locate game extension " + Session.data["Game"])
		return
	
	repaint_mods()
	var sessionName = filePath.get_file()
	console_manager.post("Loaded Session: " + sessionName)
	Globals.repaint_app_name()
	pass

#--- Resets the managers to a fresh state
func wipe_slate(skipGames=false):
	if not skipGames:
		managedGames.clear()
	if not activeGame.script == null:
		activeGame.script.extension_unloaded()
	activeGame = {
		"script":null,
		"data":null,
		"name":""
	}
	scanData = null
	Session.reset_data()
	Session.data["Game"] = ""
	Session.data["Mods"] = []
	pass

#--- Reads the setup data from the game compatibility plugin
func read_game_extension(extensionPath:String):
	var data = Functions.read_file(extensionPath)
	var dir = extensionPath.get_base_dir()
	activeGame.script = load(Functions.os_path_convert(dir+"/"+data.Script)).new()
	activeGame.data = data
	activeGame.name = extensionPath.get_file()
	activeGame.script.extension_loaded()
	Session.data["Game"] = extensionPath.get_file()
	pass

#--- Assigns options to all of the popups that MainManager interacts with.
func assign_options():
	#- Assign options to the FileMenuButton popup.
	var filePData = popup_manager.get_popup_data("FileMenu")
	filePData.register_entity(my_id, self, "handle_file_menu")
	filePData.add_option(my_id, "Open Session", KEY_O)
	filePData.add_option(my_id, "New", KEY_N)
	filePData.add_separator(my_id)
	filePData.add_option(my_id, "Save", KEY_S)
	filePData.add_option(my_id, "Save As", KEY_S, true)
	
	#- Assign Options to the EditMenuButton popup.
	var editPData = popup_manager.get_popup_data("EditMenu")
	editPData.register_entity(my_id, self, "handle_edit_menu")
	editPData.add_option(my_id, "Add Mod", KEY_A, true)
	editPData.add_option(my_id, "Import Mods", KEY_I, true)
	editPData.add_separator(my_id, "")
	editPData.add_option(my_id, "Open Mod Links")
	
	#- Assign options to the ScanMenuButton popup.
	var scanPData = popup_manager.get_popup_data("ScanMenu")
	scanPData.register_entity(my_id, self, "handle_scan_menu")
	scanPData.add_option(my_id, "Run Scan", KEY_R)
	scanPData.add_separator(my_id, "After Scan")
	scanPData.add_option(my_id, "Post Results", null, false, true)
	scanPData.add_option(my_id, "Open Links", null, false, true)
	pass

func handle_file_menu(selectedOption):
	match selectedOption:
		"Open Session":
			search_manager.search_for_session(self, "open_loaded_session")
		"New":
			window_manager.activate_window("gameSelect")
		"Save":
			if Session.has_saved():
				Session.quick_save()
				console_manager.generate("Saved Session", Globals.green)
			else:
				search_manager.search_to_save(self, "handle_save")
		"Save As":
			search_manager.search_to_save(self, "handle_save")
			pass
	pass

func handle_edit_menu(selectedOption):
	match selectedOption:
		"Add Mod":
			window_manager.activate_window("modAdd")
		"Open Mod Links":
			console_manager.generate("Opening listed mod links...", Globals.green)
			for mod in Session.data.Mods:
				if not mod.extras.Link == "":
					Functions.open_link(mod.extras.Link)
			console_manager.post("Links opened.")
		"Import Mods":
			search_manager.search_for_session(self, "mod_import")
			
	pass

func handle_scan_menu(selectedOption):
	match selectedOption:
		"Run Scan":
			console_manager.generate("Scanning mod list for compatibility...", Globals.green)
			scan_mods()
		"Post Results":
			console_manager.post("Posting scan results...")
			scanData.post_result()
		"Open Links":
			console_manager.post("Opening links to all missing mods...")
			for link in scanData.compile_links():
				Functions.open_link(link)
	pass

func handle_save(filePath):
	Session.sessionName = filePath.get_file()
	Session.save_data(filePath)
	console_manager.post("Saved Session")
	pass

func add_mod(modData):
	#modData["index"] = Session.data.Mods.size()
	Session.data.Mods.append(modData)
	repaint_mods()
	console_manager.post("Added new mod: " + modData.fields.Mods)
	Globals.repaint_app_name(true)
	reset_scan()
	pass

func edit_mod(modData, modIndex):
	#modData["index"] = modIndex # <-- This shit causes nightmares. Rework this please!!
	Session.data.Mods[modIndex] = modData
	repaint_mods()
	console_manager.post("Edited mod: " + modData.fields.Mods)
	Globals.repaint_app_name(true)
	reset_scan()
	pass

func reset_scan():
	scanData = null
	var p = popup_manager.get_popup_data("ScanMenu")
	p.lock_option(my_id, "Post Results")
	p.lock_option(my_id, "Open Links")
	pass

func scan_mods():
	if activeGame.data == null:
		console_manager.posterr("ERR1002: No Session is active. Please start a session first!")
		return
	
	if activeGame.script == null:
		console_manager.posterr("ERR1003: Game Extension does not have a script included!!")
		return
	
	scanData = activeGame.script.scan_mods(Session.data.Mods)
	scanData.post_result()
	
	if scanData.has_links():
		var p = popup_manager.get_popup_data("ScanMenu")
		p.unlock_option(my_id, "Post Results")
		p.unlock_option(my_id, "Open Links")
	pass

func repaint_mods():
	mod_tree_manager.draw_tree(activeGame.data)
	pass

func sort_mods(category:String, orientation:int):
	return activeGame.script.sort_mod_list(category, orientation, Session.data.Mods)

func mod_import(path:String):
	var data = Session.export_load_data(path)
	if not data["Game"] == activeGame.name:
		console_manager.posterr("ERR800: Cancelled attempt to import mods from a different game!")
		return
	
	window_manager.activate_window("importMod", data.Mods)
	pass

func get_mod_name(mod):
	return activeGame.script.get_mod_name(mod)
