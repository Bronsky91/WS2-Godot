extends Node2D

onready var global = get_node("/root/Global")
onready var placeholder = $Sprite
onready var hud = get_tree().get_root().get_node("Game").find_node("TowerDefenseHUD")

var disabled = false
var power_level = 1.0
var placeable = false

# class variables that include details for rune being placed 
var rune

var _rune_details
var _cost
var _color
var _max_power_level
var _range
var _placement


func _ready():
	add_to_group("placeholder")


func init_placeholder(rune_details):
	rune = load("res://Scenes/Runes/{spell}.tscn".format({"spell": rune_details["name"]}))
	_rune_details = rune_details
	_placement = rune_details["placement"]
	_cost = rune_details["cost"]
	_max_power_level = rune_details["max_power_level"]
	_color = rune_details["rune_color"]
	_range = rune_details["range"]
	

func _process(delta):
	if global.hovering_on_any_rune:
			set_visibility(false)
	elif not global.hovering_on_any_rune:
			set_visibility(true)
	position = global.cursor_tile_pos
	# Checks if rune can be placed based on mana and tile availabity
	if placeable and (global.mana < _cost or global.cursor_tile_path != _placement):
		cannot_place()
	elif not placeable and global.mana >= _cost and global.cursor_tile_path == _placement and hud.global_cooldown.is_stopped():
		can_place()


func _draw():
   	draw_circle(Vector2(0,0),_range,Color(1.0,1.0,1.0,0.3))
	# TODO: Unsure of what the other float should be in the circle_radius Vector2. Also unsure what the resolution should be.
	#draw_empty_circle(Vector2(0,0), Vector2(10,_attack_range), Color(1.0,1.0,1.0,0.5), 720)


func _input(event):
	# Watches for scrolling up or down to place the rune already powered up or back down
	if disabled:
		return
	if event.is_action_released("power_up") and power_level < _max_power_level:
		power_level += 1
		_cost = _rune_details["cost"] * power_level
		modulate = Color(_color.r / power_level, _color.g / power_level, _color.b / power_level)
	if event.is_action_released("power_down") and power_level > 1:
		power_level -= 1
		_cost -= _rune_details["cost"]
		modulate = Color(_color.r / power_level, _color.g / power_level, _color.b / power_level)
	if event.is_action_released("remove"):
		queue_free()
	if event.is_action("create") and placeable:
		var new_rune = rune.instance() # instances new rune to place
		new_rune.init(_rune_details, power_level)
		new_rune.position = global.cursor_tile_pos
		global.mana -= _cost
		cannot_place()
		hud.global_cooldown.start()
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
