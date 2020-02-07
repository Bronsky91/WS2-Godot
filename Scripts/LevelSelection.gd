extends Node

onready var global = get_node("/root/Global")
onready var levels = $Levels

func _ready():
	for button in levels.get_children():
		var level = int(button.name[-1])
		if global.level_state.completed.has(level):
			button.add_color_override('font_color', Color(0,1,0,1))
		elif level == global.level_state.current:
			button.add_color_override('font_color', Color(0,0,1,1))
		else:
			button.disabled = true

func _on_level_pressed(level):
	global.level_state.current = level
	get_tree().change_scene("res://Scenes/Game.tscn")

func _on_Return_pressed():
	get_tree().change_scene("res://Scenes/StartMenu.tscn")
