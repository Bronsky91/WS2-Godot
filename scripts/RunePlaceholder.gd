extends Node2D

export(PackedScene) var rune
onready var placeholder = $Sprite

var Mouse_Position

func _process(delta):
	Mouse_Position = get_local_mouse_position()
	position += Mouse_Position
	

func _input(event):
	if event.is_pressed() and event.button_index == BUTTON_LEFT:
		var new_rune = rune.instance()
		new_rune.position = get_global_mouse_position()
		get_tree().get_root().add_child(new_rune)
		

