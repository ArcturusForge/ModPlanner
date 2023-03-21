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

#-- Color Hexes
var clear = "#00000000"
var grey = "#b2b5bb"
var red = "#a25062"
var yellow = "#b7ab7c"

#-- Generic Scripts
const popupDataScript = preload("res://Scripts/Generics/PopupData.gd")
const managedGameScript = preload("res://Scripts/Generics/ManagedGame.gd")
const modData = preload("res://Scripts/Generics/ModData.gd")

#-- Globalizer
var managers = {}

#-- Example Mod
var exampleMod = {
		"color":"#b2b5bb",
		"fields":{
			"Mods":"Hello Word",
			"Type":"Other",
			"Version":"1.0.0",
			"Source":"Nexus",
			"Priority Order":"0",
			"Load Order":"0"
		},
		"extras":{
			"Link":"www.nexusmods.com/skyrim_se/hello_world_mod",
			"Required":[
				{
					"Name":"World in Space",
					"Link":"www.nexusmods.com/skyrim_se/world_in_space_mod"
				}
			],
			"Incompatible":[
				{
					"Patchable":true,
					"Name":"Goodbye World",
					"Link":"www.nexusmods.com/skyrim_se/goodbye_world_mod",
					"Patch":"www.nexusmods.com/skyrim_se/hello-goodbye_world_patch"
				}
			]
		}
		
	}

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
