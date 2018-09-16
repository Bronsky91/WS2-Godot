extends Control

export(PackedScene) var rune_placeholder

onready var rune_button = $RuneButton

var new_rune
var rune_type # How to know what rune this button places
var rune_count # Holds total runes on map, use to limit runes in general
var mana # References current mana

func _ready():
	# TODO: Set type of rune dynamically from player character choice and tomes
	rune_button.set_text('Rune Type')
	rune_button.set_toggle_mode(true)
	rune_button.connect("toggled", self, "_on_toggled")


func _on_toggled(button_pressed):
	if(button_pressed):
		# TODO: Create conditions with declared variables above
		new_rune = rune_placeholder.instance()
		get_tree().get_root().add_child(new_rune)
	else:
		new_rune.queue_free()

