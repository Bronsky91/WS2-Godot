extends TileMap

onready var global = get_node("/root/Global")
var cursor_cell
var mouse_pos

func _ready():
	pass

func _process(delta):
	mouse_pos = get_global_mouse_position()
	global.cursor_tile_x = int(mouse_pos.x) / global.TILE_WIDTH
	global.cursor_tile_y = int(mouse_pos.y) / global.TILE_HEIGHT
	global.cursor_tile_pos = global.get_tile_pos(global.cursor_tile_x, global.cursor_tile_y)
	#global.cursor_tile_pos = Vector2(
    #    (int(global.cursor_tile_x) * 64) + (global.TILE_WIDTH / 2),
    #    (int(global.cursor_tile_y) * 64) + (global.TILE_HEIGHT / 2)
    #)
	#print('cursor tile pos = ' + str(global.cursor_tile_pos))
	cursor_cell = get_cell(global.cursor_tile_x, global.cursor_tile_y)
	if tile_set.tile_get_navigation_polygon(cursor_cell) != null:
		global.cursor_tile_path = "in_lane"
	else:
		global.cursor_tile_path = "out_of_lane"
