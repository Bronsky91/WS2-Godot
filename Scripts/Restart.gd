extends Button

onready var global = get_node("/root/Global")


func _ready():
	pass


func _on_Restart_pressed():
	get_tree().change_scene("res://Scenes/StartMenu.tscn")
	global.restarted = true
	global.mana = global.mana_max
	global.base_hp = global.base_hp_max
	global.level_state.current = 1
	for rune in get_tree().get_nodes_in_group("runes"):
		rune.queue_free()
