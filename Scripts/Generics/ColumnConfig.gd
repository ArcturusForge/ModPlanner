extends Node

var confTitle:String setget set_title, get_title
var minWidth:int setget set_width, get_width

func set_title(t):
	confTitle = t
	pass

func get_title():
	return confTitle

func set_width(w):
	minWidth = w
	pass

func get_width():
	return minWidth

func construct(title:String, width:int):
	set_title(title)
	set_width(width)
	pass
