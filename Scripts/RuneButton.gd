extends Node

export(PackedScene) var rune_placeholder

onready var global = get_node("/root/Global")
onready var hud = get_tree().get_root().get_node("Game").find_node("TowerDefenseHUD")
onready var rune_button = $RuneButton

var placeholder
var spell_key

var _rune_details # JSON object of rune details


func _ready():
	# TODO: Set type of rune dynamically from player character choice and tomes
	rune_button.set_text(_rune_details["button_name"] + ' ' + str(spell_key))


func _input(event):
	if event.is_action_released("spell_" + str(spell_key)) and not event.is_echo():
		if get_tree().get_nodes_in_group("placeholder").size() > 0:
			for p_holder in get_tree().get_nodes_in_group("placeholder"):
				p_holder.queue_free()
		placeholder = rune_placeholder.instance()
		placeholder.init_placeholder(_rune_details)
		hud.add_child(placeholder)


func init(rune_details):
	# Inits what rune will be used when button is pressed
	_rune_details = rune_details
		

func _on_RuneButton_mouse_entered():
	global.hovering_on_rune = true


func _on_RuneButton_mouse_exited():
	global.hovering_on_rune = false


func _on_RuneButton_pressed():
	if get_tree().get_nodes_in_group("placeholder").size() > 0:
		for p_holder in get_tree().get_nodes_in_group("placeholder"):
			p_holder.queue_free()
	placeholder = rune_placeholder.instance()
	placeholder.init_placeholder(_rune_details)
	get_tree().get_root().add_child(placeholder)
	
