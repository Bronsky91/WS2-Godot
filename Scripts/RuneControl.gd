extends Control

onready var placeholder = get_node("/root/RunePlaceholder")
onready var global = get_node("/root/Global")
onready var rune = get_parent()

var circle_width = 0

func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")


func _draw():
    draw_circle(Vector2(32,32),circle_width,Color(1.0,1.0,1.0,0.3))
		

func _on_mouse_entered():
	global.hovering_on_rune = true
	rune.cursor_hovering = true
	circle_width = rune._range
	update()

func _on_mouse_exited():
	global.hovering_on_rune = false
	rune.cursor_hovering = false
	circle_width = 0
	update()
