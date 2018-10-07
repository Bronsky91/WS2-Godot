extends Node2D

export(PackedScene) var debuff_scene

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
		# If enemy is in range spell follows and hit
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
	if rune.get_ref()._debuffs:
	# if the rune has the debuff attribute
		for debuff in rune.get_ref()._debuffs:
			if not target.get_ref().afflictions.has(debuff["class"]):
			# If the enemy is not already afflicted with the current debuff of the spell
				apply_debuff(debuff)
	var global = get_node("/root/Global")
	# Increases ultimate charge
	global.increase_ult_charge(damage)
	queue_free()
	
	
func apply_debuff(debuff):
	# Applies debuff that is this spell uses
	target.get_ref().afflictions.append(debuff["class"])
	var new_debuff
	new_debuff = debuff_scene.instance()
	target.get_ref().add_child(new_debuff)
	new_debuff.init(debuff)
		
		