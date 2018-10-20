extends Node

export(PackedScene) var rune_placeholder

onready var global = get_node("/root/Global")
onready var rune_button = $RuneButton

var placeholder

var _rune_details # JSON object of rune details


func _ready():
	# TODO: Set type of rune dynamically from player character choice and tomes
	rune_button.set_text(_rune_details["button_name"])
	rune_button.set_toggle_mode(true)
	rune_button.connect("toggled", self, "_on_toggled")
	


func init(rune_details):
	# Inits what rune will be used when button is pressed
	_rune_details = rune_details
	
	
func _on_toggled(toggled):
	# while button is toggled rune placeholder appears and chosen rune can be placed
	#TODO: Refactor rune placement method to be more intutive 
	if toggled:
		placeholder = rune_placeholder.instance()
		placeholder.init_placeholder(_rune_details)
		get_tree().get_root().add_child(placeholder)
	elif not toggled:
		placeholder.queue_free()
		

func _on_RuneButton_mouse_entered():
	global.hovering_on_rune = true


func _on_RuneButton_mouse_exited():
	global.hovering_on_rune = false
