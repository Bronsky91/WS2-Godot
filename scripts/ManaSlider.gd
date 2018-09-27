extends HSlider

onready var global = get_node("/root/Global")
var rune_scale
var current_power_level
var max_power_level
var new_scale
var current_scale
var rune_cost

	
func _ready():
	set_editable(false)
	
	

func _on_ManaSlider_mouse_entered():
	set_editable(true)
	

func _on_ManaSlider_mouse_exited():
	pass
	

func _on_ManaSlider_value_changed(value):
	rune_scale = get_parent()._size
	current_scale = get_parent().get_scale().x
	if current_power_level:
		if current_power_level < value and global.mana >= rune_cost:
			global.mana -= (rune_cost * value)
			global.mana_bar(global.mana)
			get_parent().power_up(value, rune_scale * value)
			current_power_level = get_parent()._power_level
		elif current_power_level > value:
			global.mana += (rune_cost * (value + 1))
			global.mana_bar(global.mana)
			get_parent().power_down(value, current_scale - rune_scale)
			current_power_level = get_parent()._power_level
