extends "res://scripts/Mob.gd"

var _aggro_range
var dist_total

func _ready():
	add_to_group("minions")


func init(sprite, speed, health, damage, reach, attack_rate, aggro_range):
	get_node("Sprite").set_texture(load("res://Assets/" + sprite + ".png"))
	_speed =  speed
	_health = health
	_damage = damage
	_reach = reach
	_attack_rate = attack_rate
	_aggro_range = aggro_range
	default_attribute = {"speed": speed, "health": health, "damage": damage}


func _physics_process(delta):
	# if the minion has not locked onto an enemy yet, check if one is in range
	if not aggro_target:
		aggro_target = choose_target()
	
	## DETERMINE IF MOVING TOWARDS FINAL DESTINATION (OFF SCREEN) OR TOWARDS A TARGETTED ENEMY
	## -----------------------
	# check if enemy has been identified
	if has_target():
		_going_towards = aggro_target.get_ref().position
		# if so, check if this is the first iteration dealing with this enemy
		if not encounter_start:
			# if first encounter, build a new path array heading towards the enemy
			encounter_start = true
			aggro_target.get_ref().fight_me(weakref(self))
			update_path(_going_towards)
		elif encounter_start:
			# if not first encounter, only update last element in path array rather than rebuild entire array multiple times
			update_path_aggro(_going_towards)
	# if no enemy is being targeted, and the minion is not moving towards its final destination (enemy spawn point)...
	elif not has_target() and _going_towards != final_dest:
		# ensure it is not in attack mode and set it back on its way to its final destination
		aggro_target = null
		attacking = false
		attack_timer.stop()
		encounter_start = false
		_going_towards = final_dest
		if not global.end_level:
			update_path(final_dest)
	## -----------------------
	
	## MOVE TOWARDS DETERMINED DESTINATION (EITHER FINAL DESTINATION OFF SCREEN OR NEARBY ENEMY)
	## -----------------------
	# Calculate the distance to the final destination as well as the next "step" towards that destination
	dist_total = self.position.distance_to(_going_towards)
	var dist_step = self.position.distance_to(path[0])
	# If the final destination's distance is outside of the minion's reach...
	if dist_total >= _reach:
		# Rotate minion to face where it is going
		look_at(path[0])
		
		# If we are still too far from the next step, continue to head towards it
		if dist_step > 2:
			self.position = self.position.linear_interpolate(path[0], (_speed * delta)/dist_step)
		# If we have reached this step, remove it, so the next step is bumped up in line
		else:
			if path.size() > 1:
				path.remove(0)
	# If the final destination's distance is within the minion's reach, start attacking it
	else:
		if not attacking:
			reached_goal()
	## -----------------------


#func _process():
#	if path.size() > 0:
#		look_at(path[0])


func choose_target():
	var pos = get_global_position()
	
	# Check if existing target is still within range
	if has_target() and pos.distance_to(aggro_target.get_ref().position) <= _aggro_range:
		return aggro_target
	else:
		aggro_target = null
	
	# If not, check if new enemy is in range, and choose closest one if multiple
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if pos.distance_to(enemy.get_global_position()) <= _aggro_range:
			if not has_target() or nearer(enemy, aggro_target.get_ref()):
				aggro_target = weakref(enemy)	
	return aggro_target


func reached_goal():
	if path.size() == 1:
		# If we have reached the final destination, off screen, then despawn minion...
		queue_free()
	else:
		# ... otherwise, if we have reached an enemey target instead, start attacking them
		attacking = true
		attack_timer.set_wait_time(_attack_rate)
		attack_timer.start()


func _on_AttackTimer_timeout():
	# attacks goal on timeout
	if has_target() and position.distance_to(aggro_target.get_ref().position) <= _reach:
		# FIGHT TIME!
		print('fight time!')
		aggro_target.get_ref().take_damage(_damage)

