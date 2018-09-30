extends Node2D

export(PackedScene) var rune
onready var global = get_node("/root/Global")
onready var placeholder = $Sprite
var disabled = false
var power_level = 1
var enabled = true
var _rune_details
var _cost
var _color
var _max_power_level


func init_placeholder(rune_details):
	_rune_details = rune_details
	_cost = rune_details["cost"]
	_max_power_level = rune_details["max_power_level"]
	_color = rune_details["rune_color"]


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
			modulate = Color(_color.r / power_level, _color.g / power_level, _color.b / power_level)
		if event.button_index == BUTTON_WHEEL_DOWN and power_level > 1:
			power_level -= 1
			_cost -= _rune_details["cost"]
			modulate = Color(_color.r / power_level, _color.g / power_level, _color.b / power_level)
		if event.button_index == BUTTON_LEFT and enabled:
			var new_rune = rune.instance() # instances new rune to place
			new_rune.init(_rune_details, power_level)
			new_rune.position = global.cursor_tile_pos
			global.mana -= _cost
			get_tree().get_root().add_child(new_rune)
			new_rune.refresh_rune()


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