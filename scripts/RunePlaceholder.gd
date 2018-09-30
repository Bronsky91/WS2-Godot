extends Node2D

export(PackedScene) var rune
onready var global = get_node("/root/Global")
onready var placeholder = $Sprite
var disabled = false
var current_rune_scale
var power_level = 1
var enabled = true
var _rune_details

var _cost
var _rune_scale
var _max_power_level


func init_placeholder(rune_details):
	_rune_details = rune_details
	_cost = rune_details["cost"]
	_rune_scale = rune_details["size"]
	_max_power_level = rune_details["max_power_level"]


func _process(delta):
	position = global.cursor_tile_pos
	if global.mana < _cost or global.cursor_tile_path:
		disable()
	else:
		enable()


func _input(event):
	if disabled:
		return
	if event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP and power_level < _max_power_level:
			power_level += 1
			_cost = _rune_details["cost"] * power_level
			current_rune_scale = _rune_scale * power_level
			placeholder.set_scale(Vector2(current_rune_scale, current_rune_scale))
		if event.button_index == BUTTON_WHEEL_DOWN and power_level > 1:
			power_level -= 1
			_cost -= _rune_details["cost"]
			current_rune_scale -= _rune_scale
			placeholder.set_scale(Vector2(current_rune_scale, current_rune_scale))
		if event.button_index == BUTTON_LEFT and enabled:
			var new_rune = rune.instance() # instances new rune to place
			new_rune.init(_rune_details, power_level)
			new_rune.position = global.cursor_tile_pos
			if current_rune_scale:
				new_rune.power_up(power_level, current_rune_scale) # Power up function ups the cost and powers up the rune
			else:
				new_rune.power_up(power_level, _rune_scale)
			global.mana -= _cost
			global.mana_bar(global.mana)
			get_tree().get_root().add_child(new_rune)


func disable():
	enabled = false
	placeholder.modulate = Color(1,0,0)


func enable():
	enabled = true
	placeholder.modulate = Color(0,0,1)


func set_visibility(visible):
	if(visible):
		show()
		disabled = false
	else:
		hide()
		disabled = true