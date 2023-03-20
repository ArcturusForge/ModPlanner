extends Node

#-- Control
const versionId = "0.1.0"
const appName = "Mod Planner"
const sessionNameDefault = "Untitled_Session"
const saveExtension = "mplan"
const gameExtension = "mpge"

#-- Paths
var resDataPath = "res://Assets/"
var userDataPath = "user://"
var gameExtenDir = "Game Extensions"

#-- Generic Scripts
const columnConfigScript = preload("res://Scripts/Generics/ColumnConfig.gd")
const popupDataScript = preload("res://Scripts/Generics/PopupData.gd")
const managedGameScript = preload("res://Scripts/Generics/ManagedGame.gd")

#-- Globalizer
var managers = {}

func _ready():
	#- Makes sure the game extensions folder exists.
	Functions.ensure_directory(userDataPath + gameExtenDir)
	pass

#--- Repaints the app's name to indicate whether save worthy changes have been made to the session
func repaint_app_name(needsSaving:bool = false):
	if not needsSaving:
		OS.set_window_title(Globals.appName + "_" + Globals.versionId + " - " + Session.sessionName)
	else:
		OS.set_window_title(Globals.appName + "_" + Globals.versionId + " - " + Session.sessionName + " (*)")
	pass

func set_manager(name:String, manager):
	if managers.has(name):
		printerr("Overwriting an existing manager")
		return
	managers[name] = manager

func get_manager(name:String):
	if managers.has(name):
		return managers[name]
	return null
