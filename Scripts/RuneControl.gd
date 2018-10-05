extends Control

func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")


func _on_mouse_entered():
	get_parent().cursor_hovering = true


func _on_mouse_exited():
	get_parent().cursor_hovering = false