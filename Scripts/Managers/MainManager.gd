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
var managedGames = []
var activeGame

func _ready():
	wipe_slate()
	Globals.repaint_app_name()
	Globals.set_manager(my_id, self)
	
	#- Read from the game extensions folder to get a list of the supported games.
	var gameExtensions = Functions.get_all_files(Globals.userDataPath + Globals.gameExtenDir, Globals.gameExtension)
	for extension in gameExtensions:
		var game = Globals.managedGameScript.new()
		game.construct(extension)
		managedGames.append(game)
	
	#- Init the sub-managers
	popup_manager.jump_start()
	search_manager.jump_start()
	console_manager.jump_start()
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
	mod_tree_manager.draw_tree(activeGame, Session.data["Mods"])
	console_manager.post("Started New Session")
	
	#TEMP:
	add_mod(Globals.exampleMod)
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
		console_manager.posterr("ERR1001 Cannot locate game extension: " + Session.data["Game"])
		return
	
	mod_tree_manager.draw_tree(activeGame, Session.data["Mods"])
	var sessionName = filePath.get_file()
	console_manager.post("Loaded Session: " + sessionName)
	pass

#--- Resets the managers to a fresh state
func wipe_slate(skipGames=false):
	if not skipGames:
		managedGames.clear()
	activeGame = null
	Session.reset_data()
	Session.data["Game"] = ""
	Session.data["Mods"] = []
	pass

#--- Reads the setup data from the game compatibility plugin
func read_game_extension(extensionPath:String):
	var data = Functions.read_file(extensionPath)
	activeGame = data
	pass

#--- Assigns options to all of the popups that MainManager interacts with.
func assign_options():
	#- Assign options to the FileMenuButton popup
	var filePData = popup_manager.get_popup_data("FileMenu")
	filePData.register_entity(my_id, self, "handle_file_menu")
	filePData.add_option(my_id, "Open Session", KEY_O)
	filePData.add_option(my_id, "New", KEY_N)
	
	#- Assign Options to the EditMenuButton popup
	var editPData = popup_manager.get_popup_data("EditMenu")
	editPData.register_entity(my_id, self, "handle_edit_menu")
	editPData.add_option(my_id, "Add Mod", KEY_A, true)
	pass

func handle_file_menu(selectedOption):
	match selectedOption:
		"Open Session":
			search_manager.search_for_session()
		"New":
			window_manager.activate_window("gameSelect")
	pass

func handle_edit_menu(selectedOption):
	match selectedOption:
		"Add Mod":
			window_manager.activate_window("modAdd")
	pass

func add_mod(modData):
	Session.data.Mods.append(modData)
	mod_tree_manager.draw_tree(activeGame, Session.data["Mods"])
	console_manager.post("Added new mod: " + modData.fields.Mods)
	Globals.repaint_app_name(true)
	pass
