extends Node

onready var global = get_node("/root/Global")


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass


func _on_level_pressed(level):
	global.current_level = level
	get_tree().change_scene("res://Scenes/Game.tscn")