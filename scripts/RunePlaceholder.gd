extends Node2D

export(PackedScene) var rune
onready var global = get_node("/root/Global")
onready var placeholder = $Sprite
var disabled = false
var rune_scale = .25
var power_level = 1
var max_power_level = 3
var Mouse_Position
var current_rune_scale
var cost = 25


func _process(delta):
	Mouse_Position = get_local_mouse_position()
	position += Mouse_Position
		

func _input(event):
	if disabled:
		return
	if event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP and power_level < max_power_level:
			power_level += 1
			cost += 25
			current_rune_scale = rune_scale * power_level
			placeholder.set_scale(Vector2(current_rune_scale, current_rune_scale))
		if event.button_index == BUTTON_WHEEL_DOWN and power_level > 1:
			power_level -= 1
			cost -= 25
			current_rune_scale = - rune_scale
			placeholder.set_scale(Vector2(current_rune_scale, current_rune_scale))
		if event.button_index == BUTTON_LEFT and global.mana >= cost:
			var new_rune = rune.instance() # instances new rune to place
			new_rune.position = get_global_mouse_position()
			if current_rune_scale:
				_power_up(new_rune, power_level, current_rune_scale) # Power up function ups the cost and powers up the rune
			else:
				_power_up(new_rune, power_level, rune_scale)
			global.mana -=  cost 
			global.mana_bar(global.mana)
			get_tree().get_root().add_child(new_rune)
		if global.mana < cost:
			placeholder.modulate = Color(1,0,0)
		if global.mana >= cost:
			placeholder.modulate = Color(0,1,0)


func set_visibility(visible):
	if(visible):
		show()
		disabled = false
	else:
		hide()
		disabled = true
		
		
func _power_up(rune, power, r_scale):
		rune._damage *= 1.0 + (power / 10)
		rune._fire_delta = 1.0/(power + 1.0)
		rune._speed *= 1.0 + (power / 10)
		rune.set_scale(Vector2(r_scale, r_scale))
		rune.spell_scale = Vector2(1.0 + r_scale, 1.0 + r_scale)
			
			