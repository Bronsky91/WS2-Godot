extends Control

onready var placeholder = get_node("/root/RunePlaceholder")
onready var global = get_node("/root/Global")
onready var rune = get_parent()


func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")


func _on_mouse_entered():
	global.hovering_on_rune = true
	rune.cursor_hovering = true

func _on_mouse_exited():
	global.hovering_on_rune = false
	rune.cursor_hovering = false