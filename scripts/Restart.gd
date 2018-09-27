extends Button

onready var global = get_node("/root/Global")


func _ready():
	pass


func _on_Restart_pressed():
	get_tree().change_scene("res://scenes/StartMenu.tscn")
	global.restarted = true
	for rune in get_tree().get_nodes_in_group("runes"):
		rune.queue_free()
	global.mana = global.mana_max
	global.base_hp = global.base_hp_max
	glboal.current_level = 1
