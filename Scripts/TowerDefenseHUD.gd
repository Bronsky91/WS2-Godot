extends Control

onready var global = get_node("/root/Global")
onready var tome_container = $TomeContainer
onready var global_cooldown = $GlobalTimer

export(PackedScene) var rune_button

var new_rune_button


func _ready():
	# Loads runes that the player has acccess to
	# Tomes hold runes - term for research
	var i = 0
	for tome in global.tome_library['Tomes']:
		i += 1
		new_rune_button = rune_button.instance()
		new_rune_button.init(tome)
		new_rune_button.spell_key = i
		tome_container.add_child(new_rune_button)


func _on_GlobalTimer_timeout():
	global_cooldown.stop()