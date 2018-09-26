extends Node

export(PackedScene) var rune_placeholder

onready var global = get_node("/root/Global")
onready var rune_button = $RuneButton

var new_rune

var _rune_details # JSON object of rune details


func _ready():
	# TODO: Set type of rune dynamically from player character choice and tomes
	rune_button.set_text(_rune_details["button_name"])
	rune_button.set_toggle_mode(true)
	rune_button.connect("toggled", self, "_on_toggled")
	rune_button.connect("mouse_entered", global, "on_node_entered")
	rune_button.connect("mouse_exited", global, "on_node_exited")


func init(rune_details):
	_rune_details = rune_details
	
	
func _on_toggled(toggled):
	if(toggled):
		new_rune = rune_placeholder.instance()
		new_rune.init_placeholder(_rune_details)
		get_parent().add_child(new_rune)
		global.node_to_hide = weakref(new_rune)
	else:
		global.node_to_hide = null
		new_rune.queue_free()
		

