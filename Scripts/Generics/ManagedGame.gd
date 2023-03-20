extends Node

var filePath
var gameName

func construct(path:String):
	filePath = path
	gameName = path.get_file()
