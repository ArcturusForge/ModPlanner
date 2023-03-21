extends Node

#-- Scene Refs
onready var label
onready var field

#-- Assigned by System
var fieldData

func set_focus():
	field.grab_focus()
	pass

func get_value():
	#return field.text/value
	pass

func set_label(text:String):
	label.text = text
