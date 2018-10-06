extends Control

onready var global = get_node("/root/Global")
onready var tome_container = $TomeContainer
export(PackedScene) var rune_button
var new_rune_button


func _ready():
	# Loads runes that the player has acccess to
	# Tomes hold runes - term for research
	for tome in global.tome_library['Tomes']:
		new_rune_button = rune_button.instance()
		new_rune_button.init(tome)
		tome_container.add_child(new_rune_button)
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
