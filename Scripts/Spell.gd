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
	# If enemy is not null and an enemy is found within range
		var pos = get_global_position()
		if target.get_ref().get_global_position().distance_to(get_global_position()) < 10:
		# If enemy is in range follow and hit
			target_hit(rune.get_ref()._damage)
			return
		# logic to have spell rotate to face enemy while in route
		# TODO: Refactor to just look_at()?
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
	rune.get_ref().rearm() # Rearms rune to fire again once enemy is hite
	target.get_ref().take_damage(damage) # Enemy takes damage
	if not target.get_ref().afflicted:
	# If the enemy is not already afflicted with the current debuff of the spell
		debuff(rune.get_ref()._debuff)
	var global = get_node("/root/Global")
	# Increases ultimate charge
	global.increase_ult_charge(damage)
	queue_free()
	
	
func debuff(debuff_array):
	# Turns on debuff that is this spell uses
	if debuff_array:
		target.get_ref().afflicted = true
		target.get_ref().next_affliction_cycle = true
		target.get_ref().debuff_details = rune.get_ref()._debuff
		
		