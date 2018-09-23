extends Node2D

export(PackedScene) var rune
onready var global = get_node("/root/Global")
onready var placeholder = $Sprite
var disabled = false
var cost = 25
var power_level = 1.0
var max_power_level = 3.0
var Mouse_Position
var rune_scale = .25


func _process(delta):
	Mouse_Position = get_local_mouse_position()
	position += Mouse_Position
		

func _input(event):
	if disabled:
		return
	if event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			power_level += 1.0
			if power_level <= max_power_level and power_level > 0:
				cost += 25
				print("power_level = " + str(power_level))
				print("cost = " + str(cost))
				rune_scale = .25 * power_level
				placeholder.set_scale(Vector2(rune_scale, rune_scale))
		if event.button_index == BUTTON_WHEEL_DOWN:
			power_level -= 1.0
			if power_level > 0 and power_level <= max_power_level:
				cost -= 25
				print("power_level = " + str(power_level))
				print("cost = " + str(cost))
				rune_scale -= .25
				placeholder.set_scale(Vector2(rune_scale, rune_scale))
		if event.button_index == BUTTON_LEFT and global.mana >= cost:
			var new_rune = rune.instance()
			new_rune.position = get_global_mouse_position()
			_balance_power(power_level)
			_power_up(new_rune, power_level) # Power up function ups the cost and powers up the rune
			global.mana -=  cost 
			global.mana_bar(global.mana)
			print("mana = " + str(global.mana))
			print("cost = " + str(cost))
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
		
		
func _power_up(rune, power):
		rune.damage *= 1.0 + (power / 10)
		rune.fire_delta = 1.0/(power + 1.0)
		rune.speed *= 1.0 + (power / 10)
		if rune_scale:
			rune.set_scale(Vector2(rune_scale, rune_scale))
			rune.spell_scale = Vector2(1.0 + rune_scale, 1.0 + rune_scale)
			
			
func _balance_power(power):
	if power > max_power_level:
		power_level = max_power_level
	if power < 0:
		power_level = 1.0