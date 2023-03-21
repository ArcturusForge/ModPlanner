extends Control

#-- Constants
const my_id = "gselectwindow"
const popup_id = "gameselect"

#-- Assigned by system
var window_manager

#-- Scene Refs
var mainManager
onready var game_tree = $Border2/BG/ScrollContainer/GameTree

#-- Dynamic Vars
var selectedGame

#--- Called when the window is added to the scene.
func _create():
	mainManager = Globals.get_manager("main")
	pass

#--- Called when the window is activated.
func _enable():
	render_game_tree(mainManager.managedGames)
	pass

#--- Called when the window is deactivated.
func _disable():
	pass

#--- Called when the window is removed from the scene.
func _destroy():
	pass

#--- Generates the options of supported games for the user to select in the game tree.
func render_game_tree(gameList):
	game_tree.clear()
	var root = game_tree.create_item()
	for game in gameList:
		var node:TreeItem = game_tree.create_item(root)
		node.set_text(0, game.gameName)
		node.set_metadata(0, game)
	pass

func _on_SelectButton_pressed():
	mainManager.start_new_session(selectedGame.filePath)
	window_manager.disable_window()
	pass

func _on_CancelButton_pressed():
	if mainManager.activeGame == null:
		window_manager.activate_window("openSelect")
	else:
		window_manager.disable_window()
	pass

func _on_GameTree_item_selected():
	var selected:TreeItem = game_tree.get_selected()
	selectedGame = selected.get_metadata(0)
	pass
	
func _on_GameTree_item_activated():
	if not selectedGame == null:
		_on_SelectButton_pressed()
	pass
