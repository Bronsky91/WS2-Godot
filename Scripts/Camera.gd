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
var g_mouse_pos
	

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
	g_mouse_pos = get_global_mouse_position()
	g_mouse_pos = Vector2(ceil(g_mouse_pos.x), ceil(g_mouse_pos.y))
	
	if panning:
		# reset destination vector
		dest_pos = camera_clamp(mouse_pos)
		# lerp camera towards mouse position
		camera_pos.position = camera_pos.position.linear_interpolate(mouse_pos, delta * pan_speed)
	else:
		# right
		var pixel_margin = drag_margin_right * screen_size.x
		
		
		if (mouse_pos.x > screen_size.x - (drag_margin_right * screen_size.x) and g_mouse_pos.x < global.level_size.x - (pixel_margin * global.zoom_level)):
			dest_pos.x += pan_speed
		# left
		if (mouse_pos.x < (drag_margin_left * screen_size.x)):
			dest_pos.x -= pan_speed
		# up
		if (mouse_pos.y > screen_size.y - (drag_margin_bottom * screen_size.y) and g_mouse_pos.y < global.level_size.y - (pixel_margin * global.zoom_level)):
			dest_pos.y += pan_speed
		# down
		if (mouse_pos.y < (drag_margin_top * screen_size.y)):
			dest_pos.y -= pan_speed
		# ensure destination position is not beyond camera limits
		
		dest_pos = camera_clamp(dest_pos)
		# lerp camera towards destination vector
		camera_pos.position = camera_pos.position.linear_interpolate(dest_pos, delta * pan_speed)



func _input(event):
	# zoom in
	if event.is_action_pressed("zoom_in"):
		print('camera_pos.position = ' + str(camera_pos.position))
		global.zoom_level -= global.zoom_speed
		if global.zoom_level < global.zoom_in_max:
			global.zoom_level = global.zoom_in_max
		zoom = Vector2(global.zoom_level, global.zoom_level)
		#camera_pos.position.x = global.level_size.x / 2
		#camera_pos.position.y = global.level_size.y / 2
		#dest_pos = Vector2(camera_pos.position.y, camera_pos.position.x)
		sync_bounds()
	# zoom out
	if event.is_action_pressed("zoom_out"):
		print('camera_pos.position = ' + str(camera_pos.position))
		global.zoom_level += global.zoom_speed
		if global.zoom_level > global.zoom_out_max:
			global.zoom_level = global.zoom_out_max
		zoom = Vector2(global.zoom_level, global.zoom_level)
		#camera_pos.position.x = global.level_size.x / 2
		#camera_pos.position.y = global.level_size.y / 2
		#dest_pos = Vector2(camera_pos.position.y, camera_pos.position.x)
		sync_bounds()
	# pan
	if event.is_action_pressed("pan"):
		panning = true
		print("panning")
	if event.is_action_released("pan"):
		panning = false
		print("no longer panning")


func set_boundary():
	limit_left = 0
	limit_right = global.level_size.x
	limit_top = 0
	limit_bottom = global.level_size.y


func camera_clamp(pos):
	#var screen_limit_right = global.cursor_tile_pos
	return Vector2( clamp(pos.x,limit_left,limit_right), clamp(pos.y,limit_top,limit_bottom) )


# TODO: Prevent zooming beyond edge of tilemap
func sync_bounds():
	var viewport = get_viewport()
	if viewport != null:
		#var zoom = get_zoom()
		var level_scale = Vector2(1 / zoom.x, 1 / zoom.y)
		
		var resolution = viewport.get_visible_rect().size
		print("level_size: " + str(global.level_size) + ", resolution: " + str(resolution) + ", pos: " + str(camera_pos.position) + \
		", zoom_level: " + str(global.zoom_level) + ", level_scale: " + str(level_scale) + 'g_mouse_pos = ' + str(g_mouse_pos))
		
		
func _draw():
   	draw_circle(camera_pos.position, 50, Color(1.0,1.0,1.0,0.8))