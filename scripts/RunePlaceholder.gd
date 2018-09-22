extends Node2D

export(PackedScene) var rune
onready var global = get_node("/root/Global")
onready var placeholder = $Sprite
var disabled = false
var cost = 25
var Mouse_Position

func _process(delta):
	Mouse_Position = get_local_mouse_position()
	position += Mouse_Position
		

func _input(event):
	if disabled:
		return
	if event.is_pressed() and event.button_index == BUTTON_LEFT and global.mana >= cost:
		var new_rune = rune.instance()
		new_rune.position = get_global_mouse_position()
		get_tree().get_root().add_child(new_rune)
		global.mana -= cost
		global.mana_bar(global.mana)
	if global.mana < cost:
		placeholder.modulate = Color(1,0,0)
	

func set_visibility(visible):
	if(visible):
		show()
		disabled = false
	else:
		hide()
		disabled = true