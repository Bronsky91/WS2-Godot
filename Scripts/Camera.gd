extends Camera2D

onready var global = get_node("/root/Global")
onready var screen_size = get_viewport_rect().size
onready var camera_pos = get_parent()
var edge_threshold = 100
var pan_speed = 10
var mouse_pos = Vector2(0,0)
var last_mouse_pos = Vector2(0,0)
var dest_pos = Vector2(0,0)
var panning = false

func _ready():
	global.camera = weakref(self)
	mouse_pos = get_viewport().get_mouse_position()
	dest_pos = mouse_pos
	# set camera to match screen size
	camera_pos.position.x = screen_size.x / 2
	camera_pos.position.y = screen_size.y / 2


func _process(delta):
	last_mouse_pos = mouse_pos
	mouse_pos = get_viewport().get_mouse_position()
	
	if panning:
		# reset destination vector
		dest_pos = camera_clamp(mouse_pos)
		# lerp camera towards mouse position
		camera_pos.position = camera_pos.position.linear_interpolate(mouse_pos, delta * pan_speed)
	else:
		# right
		if (mouse_pos.x > screen_size.x - (drag_margin_right * screen_size.x)):
			dest_pos.x += pan_speed
		# left
		if (mouse_pos.x < (drag_margin_left * screen_size.x)):
			dest_pos.x -= pan_speed
		# up
		if (mouse_pos.y > screen_size.y - (drag_margin_top * screen_size.y)):
			dest_pos.y += pan_speed
		# down
		if (mouse_pos.y < (drag_margin_bottom * screen_size.y)):
			dest_pos.y -= pan_speed
		# ensure destination position is not beyond camera limits
		dest_pos = camera_clamp(dest_pos)
		# lerp camera towards destination vector
		camera_pos.position = camera_pos.position.linear_interpolate(dest_pos, delta * pan_speed)



func _input(event):
	# zoom in
	if event.is_action_pressed("zoom_in"):
		global.zoom_level -= global.zoom_speed
		if global.zoom_level < -global.zoom_max:
			global.zoom_level = -global.zoom_max
		zoom = Vector2(global.zoom_level, global.zoom_level)
	# zoom out
	if event.is_action_pressed("zoom_out"):
		global.zoom_level += global.zoom_speed
		if global.zoom_level > global.zoom_max:
			global.zoom_level = global.zoom_max
		zoom = Vector2(global.zoom_level, global.zoom_level)
	# pan
	if event.is_action_pressed("pan"):
		panning = true
		print("panning")
	if event.is_action_released("pan"):
		panning = false
		print("no longer panning")


func set_boundary(size):
	limit_left = 0
	limit_right = global.TILE_WIDTH * size.x
	limit_top = 0
	limit_bottom = global.TILE_WIDTH * size.y


func camera_clamp(pos):
	return Vector2( clamp(pos.x,limit_left,limit_right),clamp(pos.y,limit_top,limit_bottom) )