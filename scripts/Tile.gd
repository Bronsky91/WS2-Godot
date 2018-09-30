extends Sprite

onready var global = get_node("/root/Global")

func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	pass

func _on_mouse_entered():
	print("setting tile pos")
	global.cursor_tile_pos = self.position
