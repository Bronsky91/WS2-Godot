extends Button

onready var global = get_node("/root/Global")

func _ready():
	pass


func _on_Continue_pressed():
	global.mana = global.mana_max
	global.base_hp = global.base_hp_max
	for rune in get_tree().get_nodes_in_group("runes"):
		rune.queue_free()
	get_tree().change_scene("res://Scenes/Game.tscn")
