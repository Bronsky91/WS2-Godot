extends Button

export(PackedScene) var rune

var rune_type # How to know what rune this button places
var rune_count # Holds total runes on map, use to limit runes in general
var mana # References current mana

func _ready():
	pass


func _on_RuneButton_pressed():
	# TODO: Create conditions with declared variables above
	var new_rune = rune.instance()
	get_tree().get_root().add_child(new_rune)