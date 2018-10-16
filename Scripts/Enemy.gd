extends "res://Scripts/Mob.gd"


func _ready():
	add_to_group("enemies")


func init(sprite, speed, health, damage, reach, attack_rate):
	get_node("Sprite").set_texture(load("res://Assets/" + sprite + ".png"))
	_speed =  speed
	_health = health
	_damage = damage
	_reach = reach
	_attack_rate = attack_rate
	default_attribute = {"speed": speed, "health": health, "damage": damage}


func _physics_process(delta):
	## DETERMINE IF MOVING TOWARDS FINAL DESTINATION (TOWER) OR TOWARDS AN AGGRO'D MINION
	## -----------------------
	# check if we are targetting aggro'd minion
	if has_target():
		_going_towards = aggro_target.get_ref().position
		# if so, check if this is the first iteration dealing with this minion
		if not encounter_start:
			# if first encounter, build a new path array heading towards the minion
			encounter_start = true
			update_path(_going_towards)
		else:
			# if not first encounter, only update last element in path array rather than rebuild entire array multiple times
			update_path_aggro(_going_towards)
	# if enemy is not targetting aggro'd minion, and is not moving towards its final destination (tower)...
	elif not has_target() and _going_towards != final_dest:
		# ensure it is not in attack mode and set it back on its way to its final destination
		attacking = false
		attack_timer.stop()
		encounter_start = false
		_going_towards = final_dest
		update_path(final_dest)
	## -----------------------
	
	## MOVE TOWARDS DETERMINED DESTINATION (EITHER FINAL DESTINATION TOWER OR AGGRO'D MINION)
	## -----------------------
	# Calculate the distance to the final destination as well as the next "step" towards that destination
	var dist_total = self.position.distance_to(_going_towards)
	var dist_step = self.position.distance_to(path[0])
	# If the final destination's distance is outside of the enemy's reach...
	if dist_total > _reach:
		# Rotate enemy to face where it is going
		look_at(path[0])
		
		# If we are still too far from the next step, continue to head towards it
		if dist_step > 2:
			self.position = self.position.linear_interpolate(path[0], (_speed * delta)/dist_step)
		# If we have reached this step, remove it, so the next step is bumped up in line
		else:
			path.remove(0)
	# If the final destination's distance is within the enemy's reach, start attacking it
	else:
		if not attacking:
			reached_goal()
	## -----------------------


func reached_goal():
	# Called when enemy reaches base
	attacking = true
	attack_timer.set_wait_time(_attack_rate)
	attack_timer.start()


func _die():
	# if this enemy was being targetted by a minion, unaggro the minion
	if has_target():
		aggro_target.get_ref().attacking = false
		aggro_target.get_ref().encounter_start = false
		attack_timer.stop()
		
	# explosion / death animation
	queue_free()


func _on_AttackTimer_timeout():
	# attacks goal on timeout
	if has_target() and position.distance_to(aggro_target.get_ref().position) <= _reach:
		# FIGHT TIME!
		print('fight time!')
		aggro_target.get_ref().take_damage(_damage)
	else:
		global.hit_base(_damage)
		print(get_name() + " attacking harry potter's house")