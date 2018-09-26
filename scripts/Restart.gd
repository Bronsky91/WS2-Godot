extends Button

onready var global = get_node("/root/Global")


func _ready():
	pass


func _on_Restart_pressed():
	get_tree().change_scene("res://scenes/StartMenu.tscn")
	global.restarted = true
	
