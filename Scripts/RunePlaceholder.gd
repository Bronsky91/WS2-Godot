extends Node2D

export(PackedScene) var rune
onready var global = get_node("/root/Global")
onready var placeholder = $Sprite
var disabled = false
var power_level = 1
var placeable = true

# class variables that include details for rune being placed 
var _rune_details
var _cost
var _color
var _max_power_level
var _attack_range


func init_placeholder(rune_details):
	_rune_details = rune_details
	_cost = rune_details["cost"]
	_max_power_level = rune_details["max_power_level"]
	_color = rune_details["rune_color"]
	_attack_range = rune_details["attack_range"]


func _process(delta):
	position = global.cursor_tile_pos
	# Checks if rune can be placed based on mana and tile availabity
	if global.mana < _cost or global.cursor_tile_path:
		cannot_place()
	else:
		can_place()

func _draw():
    draw_circle(Vector2(0,0),_attack_range,Color(1.0,1.0,1.0,0.5))
	# TODO: Unsure of what the other float should be in the circle_radius Vector2. Also unsure what the resolution should be.
	#draw_empty_circle(Vector2(0,0), Vector2(10,_attack_range), Color(1.0,1.0,1.0,0.5), 720)

# https://www.reddit.com/r/godot/comments/3ktq39/drawing_empty_circles_and_curves/
# TODO: Figure this out. Does not seem to work right, as-is...
func draw_empty_circle (circle_center, circle_radius, color, resolution):
	var draw_counter = 1
	var line_origin = Vector2()
	var line_end = Vector2()
	line_origin = circle_radius + circle_center
	
	while draw_counter <= 360:
		line_end = circle_radius.rotated(deg2rad(draw_counter)) + circle_center
		draw_line(line_origin, line_end, color)
		draw_counter += 1 / resolution
		line_origin = line_end
		
	line_end = circle_radius.rotated(deg2rad(360)) + circle_center
	draw_line(line_origin, line_end, color)


func _input(event):
	# Watches for scrolling up or down to place the rune already powered up or back down
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
		if event.button_index == BUTTON_LEFT and placeable:
			var new_rune = rune.instance() # instances new rune to place
			new_rune.init(_rune_details, power_level)
			new_rune.position = global.cursor_tile_pos
			global.mana -= _cost
			get_tree().get_root().add_child(new_rune)
			new_rune.refresh_rune()


func cannot_place():
	# Changes color to represent not being able to place a rune
	placeable = false
	placeholder.modulate = Color(1,0,0)


func can_place():
	placeable = true
	placeholder.modulate = Color(0,0,1)


func set_visibility(visible):
	# Disables placeholder if player is hovering over button to select new rune
	if(visible):
		show()
		disabled = false
	else:
		hide()
		disabled = true