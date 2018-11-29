extends Camera2D

onready var global = get_node("/root/Global")
onready var screen_size = get_viewport_rect().size
onready var camera_pivot = get_parent()
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
	#camera_pivot.position.x = screen_size.x / 2
	#camera_pivot.position.y = screen_size.y / 2


func _process(delta):
	last_mouse_pos = mouse_pos
	mouse_pos = get_viewport().get_mouse_position()
	g_mouse_pos = get_global_mouse_position()
	g_mouse_pos = Vector2(ceil(g_mouse_pos.x), ceil(g_mouse_pos.y))
	
	if panning:
		# reset destination vector
		dest_pos = camera_clamp(mouse_pos)
		# lerp camera towards mouse position
		camera_pivot.position = camera_pivot.position.linear_interpolate(mouse_pos, delta * pan_speed)
	else:
		var pan_margin = Vector2(drag_margin_right * screen_size.x, drag_margin_bottom * screen_size.y)
		
		# right
		if (mouse_pos.x > screen_size.x - (drag_margin_right * screen_size.x) and g_mouse_pos.x < global.level_size.x - (pan_margin.x * global.zoom_level)):
			dest_pos.x += pan_speed
		# left
		if (mouse_pos.x < (drag_margin_left * screen_size.x)):
			dest_pos.x -= pan_speed
		# up
		if (mouse_pos.y > screen_size.y - (drag_margin_bottom * screen_size.y) and g_mouse_pos.y < global.level_size.y - (pan_margin.y * global.zoom_level)):
			dest_pos.y += pan_speed
		# down
		if (mouse_pos.y < (drag_margin_top * screen_size.y)):
			dest_pos.y -= pan_speed
		# ensure destination position is not beyond camera limits
		
		dest_pos = camera_clamp(dest_pos)
		# lerp camera towards destination vector
		camera_pivot.position = camera_pivot.position.linear_interpolate(dest_pos, delta * pan_speed)



func _input(event):
	# zoom in
	if event.is_action_pressed("zoom_in"):
		var rollback_zoom_level = global.zoom_level
		global.zoom_level -= global.zoom_speed
		if global.zoom_level < global.zoom_in_max:
			global.zoom_level = global.zoom_in_max
		clipped_zoom(rollback_zoom_level)
	# zoom out
	if event.is_action_pressed("zoom_out"):
		var rollback_zoom_level = global.zoom_level
		global.zoom_level += global.zoom_speed
		if global.zoom_level > global.zoom_out_max:
			global.zoom_level = global.zoom_out_max
		clipped_zoom(rollback_zoom_level)
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


func clipped_zoom(var rollback_zoom_level):
	# Zoom to new new zoom level, unless it will go beyond the edge of the tilemap
	
	var viewport = get_viewport()
	if viewport != null:
		#print("setting zoom to : " + str(global.zoom_level))
		zoom = Vector2(global.zoom_level, global.zoom_level)
		
		var cam_pos = get_camera_position()
		var scaled_resolution = viewport.get_visible_rect().size * global.zoom_level
		if( 
			cam_pos.x < limit_left or \
			cam_pos.y < limit_top or \
			cam_pos.x + scaled_resolution.x > limit_right or \
			cam_pos.y + scaled_resolution.y > limit_bottom \
		):
			#print("rolling back zoom to: " + str(rollback_zoom_level))
			global.zoom_level = rollback_zoom_level
			zoom = Vector2(global.zoom_level, global.zoom_level)
		
		#var level_scale = Vector2(1 / zoom.x, 1 / zoom.y)
		#var cam_center = get_camera_screen_center()
		#var resolution = viewport.get_visible_rect().size
		#print("level_size: " + str(global.level_size) + ", resolution: " + str(resolution) + ", pos: " + str(camera_pivot.position) + \
		#", zoom_level: " + str(global.zoom_level) + ", level_scale: " + str(level_scale) + ', g_mouse_pos : ' + str(g_mouse_pos) + \
		#', cam_pos: ' + str(cam_pos) + ', cam_center: ' + str(cam_center) + ', scaled_cam_center: ' + str(scaled_cam_center) + \
		#', scaled_resolution: ' + str(scaled_resolution))
		
		
func _draw():
	#var viewport = get_viewport()
	#var resolution = viewport.get_visible_rect().size
	#var cam_pos = get_camera_position()
	#var cam_center = get_camera_screen_center()
	#var scaled_resolution = resolution * global.zoom_level
	#var scaled_cam_center = Vector2(cam_center.x - (scaled_resolution.x / 2), cam_center.y - (scaled_resolution.y / 2))
	#draw_circle(camera_pivot.position, 50, Color(1.0,1.0,1.0,0.8))
	#draw_circle(cam_pos, 50, Color(1.0,0.0,0.0,0.8))
	#draw_circle(cam_center, 50, Color(0.0,1.0,0.0,0.8))
	#draw_circle(scaled_cam_center, 100, Color(0.0,1.0,0.0,0.8))
	pass