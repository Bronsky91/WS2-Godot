extends Camera2D

onready var global = get_node("/root/Global")
onready var screen_size = get_viewport_rect().size
onready var cam_pivot = get_parent()
var edge_threshold = 100
var pan_speed = 10
var mouse_pos = Vector2(0,0)
var last_mouse_pos = Vector2(0,0)
var dest_pos = Vector2(0,0)
var panning = false
var g_mouse_pos
var rollback_zoom = false
var temp_cam_pos = Vector2()
var rollback_count = 0
var pan_dir: String


func _ready():
	global.camera = weakref(self)
	mouse_pos = get_viewport().get_mouse_position()
	dest_pos = mouse_pos
	# set camera to match screen size
	#cam_pivot.position.x = screen_size.x / 2
	#cam_pivot.position.y = screen_size.y / 2

func move_cam(pos):
	if pan_dir == "left":
		pos.x = pos.x - 100
	if pan_dir == "right":
		pos.x =+ pos.x + 100
	if pan_dir == "up":
		pos.y = pos.y - 100
	if pan_dir == "down":
		pos.y =+ pos.y + 100
	return pos

func _process(delta):
	last_mouse_pos = mouse_pos
	mouse_pos = get_viewport().get_mouse_position()
	g_mouse_pos = get_global_mouse_position()
	g_mouse_pos = Vector2(ceil(g_mouse_pos.x), ceil(g_mouse_pos.y))
	
	if panning:
		# lerp camera towards pan direction
		cam_pivot.position = cam_pivot.position.linear_interpolate(move_cam(cam_pivot.position), delta * pan_speed)
		# reset destination vector
		dest_pos = cam_pivot.position
		dest_pos = camera_clamp(dest_pos)
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
		cam_pivot.position = cam_pivot.position.linear_interpolate(dest_pos, delta * pan_speed)


func _input(event):
	# zoom in
	if event.is_action_pressed("zoom_in") and global.zoom_level != global.zoom_in_max:
		var rollback_zoom_level = global.zoom_level
		global.zoom_level -= global.zoom_speed
		if global.zoom_level < global.zoom_in_max:
			global.zoom_level = global.zoom_in_max
		try_zoom(rollback_zoom_level)
	# zoom out
	if event.is_action_pressed("zoom_out") and global.zoom_level != global.zoom_out_max:
		var rollback_zoom_level = global.zoom_level
		global.zoom_level += global.zoom_speed
		if global.zoom_level > global.zoom_out_max:
			global.zoom_level = global.zoom_out_max
		try_zoom(rollback_zoom_level)
	# pan
	if event.is_action_pressed("pan"):
		panning = true
		if event.is_action_pressed("pan_left"):
			pan_dir = "left"
		if event.is_action_pressed("pan_right"):
			pan_dir = "right"
		if event.is_action_pressed("pan_down"):
			pan_dir = "down"
		if event.is_action_pressed("pan_up"):
			pan_dir = "up"
		if event.is_action_pressed("pan_up") and event.is_action_pressed("pan_left"):
			print('up and left')
	if event.is_action_released("pan"):
		panning = false


func set_boundary():
	limit_left = 0
	limit_right = global.level_size.x
	limit_top = 0
	limit_bottom = global.level_size.y


func camera_clamp(pos):
	#var screen_limit_right = global.cursor_tile_pos
	return Vector2( clamp(pos.x,limit_left,limit_right), clamp(pos.y,limit_top,limit_bottom) )


# Zoom to new new zoom level, unless it will go beyond the edge of the tilemap
func try_zoom(var rollback_zoom_level):
	# ensure rollback_zoom starts out false
	rollback_zoom = false
	
	
	# Get upper left camera position and what the new scaled screen resolution is
	#temp_cam_pos = get_camera_position()
	var scaled_resolution = get_viewport().get_visible_rect().size * global.zoom_level
	scaled_resolution = Vector2(round(scaled_resolution.x), round(scaled_resolution.y))
	temp_cam_pos = Vector2(g_mouse_pos.x - (scaled_resolution.x / 2), g_mouse_pos.y - (scaled_resolution.y / 2))
	
	# Make sure zoom does not exceed map boundaries
	rollback_count = 0
	smart_zoom(scaled_resolution)
	
	# If smart_zoom() was unable to make the zoom work without exceeding map boundaries, rollback to previous zoom level
	if rollback_zoom:
		global.zoom_level = rollback_zoom_level
	# Otherwise, zoom and reset destination position so camera doesn't immediately pan after zoom
	else:
		cam_pivot.position = temp_cam_pos
		dest_pos = camera_clamp(temp_cam_pos)
		zoom = Vector2(global.zoom_level, global.zoom_level)


func smart_zoom(var scaled_resolution):
	# As this function is called recursively, if previous run failed out then don't waste time and return
	if rollback_zoom:
		return;
		
	if rollback_count > 5:
		print("TOO MUCH ZOOM FINAGLIN'")
		rollback_zoom = true
		return
		
	var delta = 0
	temp_cam_pos = Vector2(round(temp_cam_pos.x), round(temp_cam_pos.y))
	
	print("[" + str(rollback_count) + "] " + "temp_cam_pos: " + str(temp_cam_pos) + ", new_zoom: " + str(global.zoom_level))
	rollback_count += 1
	# if zooming will result in camera being out-of-bounds to the LEFT...
	if temp_cam_pos.x < limit_left:
		# check if camera can be moved to still allow the zoom
		delta = limit_left - temp_cam_pos.x
		# if move can work, do it, then re-call this function recursively to retest with adjusted position
		if temp_cam_pos.x + delta + scaled_resolution.x < limit_right:
			#print("Out-of-bounds LEFT. Delta: " + str(delta) + ", Scaled_Res: " + str(scaled_resolution) + ", Right_Limit: " + str(limit_right) + ". Moving from " + str(temp_cam_pos) + " to " + str(temp_cam_pos.x + delta) + "," + str(temp_cam_pos.y))
			temp_cam_pos = Vector2(temp_cam_pos.x + delta, temp_cam_pos.y)
			smart_zoom(scaled_resolution)
		# otherwise, set rollback flag to true and return
		else:
			#print("Out-of-bounds LEFT. Delta: " + str(delta) + ", Scaled_Res: " + str(scaled_resolution) + ", Right_Limit: " + str(limit_right) + ". Unable to move from " + str(temp_cam_pos))
			rollback_zoom = true
			return
	
	# if zooming will result in camera being out-of-bounds to the TOP...
	if temp_cam_pos.y < limit_top:
		# check if camera can be moved to still allow the zoom
		delta = limit_top - temp_cam_pos.y
		# if move can work, do it, then re-call this function recursively to retest with adjusted position
		if temp_cam_pos.y + delta + scaled_resolution.y < limit_bottom:
			#print("Out-of-bounds TOP. Delta: " + str(delta) + ", Scaled_Res: " + str(scaled_resolution) + ", Bottom_Limit: " + str(limit_bottom) + ". Moving from " + str(temp_cam_pos) + " to " + str(temp_cam_pos.x) + "," + str(temp_cam_pos.y + delta))
			temp_cam_pos = Vector2(temp_cam_pos.x, temp_cam_pos.y + delta)
			smart_zoom(scaled_resolution)
		# otherwise, set rollback flag to true and return
		else:
			#print("Out-of-bounds TOP. Delta: " + str(delta) + ", Scaled_Res: " + str(scaled_resolution) + ", Bottom_Limit: " + str(limit_bottom) + ". Unable to move from " + str(temp_cam_pos))
			rollback_zoom = true
			return
	
	# if zooming will result in camera being out-of-bounds to the RIGHT...
	if temp_cam_pos.x + scaled_resolution.x > limit_right:
		# check if camera can be moved to still allow the zoom
		delta = temp_cam_pos.x + scaled_resolution.x - limit_right
		# if move can work, do it, then re-call this function recursively to retest with adjusted position
		if temp_cam_pos.x - delta >= limit_left:
			#print("Out-of-bounds RIGHT. Delta: " + str(delta) + ", Scaled_Res: " + str(scaled_resolution) + ", Right_Limit: " + str(limit_right) + ". Moving from " + str(temp_cam_pos) + " to " + str(temp_cam_pos.x - delta) + "," + str(temp_cam_pos.y))
			temp_cam_pos = Vector2(temp_cam_pos.x - delta, temp_cam_pos.y)
			smart_zoom(scaled_resolution)
		# otherwise, set rollback flag to true and return
		else:
			#print("Out-of-bounds RIGHT. Delta: " + str(delta) + ", Scaled_Res: " + str(scaled_resolution) + ", Right_Limit: " + str(limit_right) + ". Unable to move from " + str(temp_cam_pos))
			rollback_zoom = true
			return
	
	# if zooming will result in camera being out-of-bounds to the BOTTOM...
	if temp_cam_pos.y + scaled_resolution.y > limit_bottom:
		# check if camera can be moved to still allow the zoom
		delta = temp_cam_pos.y + scaled_resolution.y - limit_bottom
		# if move can work, do it, then re-call this function recursively to retest with adjusted position
		if temp_cam_pos.y - delta >= limit_top:
			#print("Out-of-bounds BOTTOM. Delta: " + str(delta) + ", Scaled_Res: " + str(scaled_resolution) + ", Bottom_Limit: " + str(limit_bottom) + ". Moving from " + str(temp_cam_pos) + " to " + str(temp_cam_pos.x) + "," + str(temp_cam_pos.y - delta))
			temp_cam_pos = Vector2(temp_cam_pos.x, temp_cam_pos.y - delta)
			smart_zoom(scaled_resolution)
		# otherwise, set rollback flag to true and return
		else:
			#print("Out-of-bounds BOTTOM. Delta: " + str(delta) + ", Scaled_Res: " + str(scaled_resolution) + ", Bottom_Limit: " + str(limit_bottom) + ". Unable to move from " + str(temp_cam_pos))
			rollback_zoom = true
			return


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