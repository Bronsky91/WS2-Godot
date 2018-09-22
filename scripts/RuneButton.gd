extends Control

export(PackedScene) var rune_placeholder

onready var global = get_node("/root/Global")
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
	rune_button.connect("mouse_entered", self, "_on_mouse_entered")
	rune_button.connect("mouse_exited", self, "_on_mouse_exited")

func _on_toggled(toggled):
	if(toggled):
		# TODO: Create conditions with declared variables above
		new_rune = rune_placeholder.instance()
		get_tree().get_root().add_child(new_rune)
		global.placeholder_cursor = weakref(new_rune)
	else:
		global.placeholder_cursor = null
		new_rune.queue_free()
		
func _on_mouse_entered():
	if(global.placeholder_cursor != null and global.placeholder_cursor.get_ref()):
		print('mouse entered')
		global.placeholder_cursor.get_ref().set_visibility(false)
		
func _on_mouse_exited():
	if(global.placeholder_cursor != null and global.placeholder_cursor.get_ref()):
		print('mouse exited')
		global.placeholder_cursor.get_ref().set_visibility(true)
