extends Node2D

var direction = Vector2(0, -1)
var target = null
var rune = null


func _ready():
	pass


func _process(delta):
	pass


func _physics_process(delta):
	if target and target.get_ref():
		var pos = get_global_position()
		if target.get_ref().get_global_position().distance_to(get_global_position()) < 10:
			target_hit(rune.get_ref()._damage)
			return
		direction = (target.get_ref().get_global_position() - pos).normalized()
		var rad_angle = atan2(-direction.x, direction.y)
		set_rotation(rad_angle)
		set_position(pos + (direction * rune.get_ref()._speed * delta))
	else:
		# TODO: special animation or behavior for fireball whose target dies before reaching it?
		# TODO: extra logic to account for runes that may be destroyed before this part of the spell code is executed
		rune.get_ref().rearm()
		queue_free()


func target_hit(damage):
	# TODO: extra logic to account for runes that may be destroyed before this part of the spell code is executed
	rune.get_ref().rearm()
	target.get_ref().take_damage(damage)
	# Conditional for debuff
	if not target.get_ref().afflicted:
		debuff(rune.get_ref()._debuff)
	var global = get_node("/root/Global")
	global.increase_ult_charge(damage)
	queue_free()
	
	
func debuff(debuff_array):
	if debuff_array:
		target.get_ref().afflicted = true
		target.get_ref().next_affliction_cycle = true
		target.get_ref().debuff_details = rune.get_ref()._debuff
		
		