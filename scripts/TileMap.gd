extends TileMap

onready var global = get_node("/root/Global")
var cursor_cell

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	cursor_cell = get_cell(global.cursor_tile_x, global.cursor_tile_y)
	print(cursor_cell)
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
