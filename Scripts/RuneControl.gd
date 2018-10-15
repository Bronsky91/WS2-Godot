extends Control

onready var placeholder = get_node("/root/RunePlaceholder")
onready var global = get_node("/root/Global")


func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")


func _on_mouse_entered():
	global.hovering_on_rune = true

func _on_mouse_exited():
	global.hovering_on_rune = false