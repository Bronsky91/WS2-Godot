extends "Mob.gd"

onready var death_timer = $DeathTimer

var _aggro_range
var dist_total
var _summoner_id
var _d_timer

func _ready():
	add_to_group("minions")
	death_timer.set_wait_time(_d_timer)
	death_timer.start()


func init(sprite, speed, health, damage, reach, attack_rate, aggro_range, death_timer, summoner_id):
	get_node("Sprite").set_texture(load("res://Assets/" + sprite + ".png"))
	_speed =  speed
	_health = health
	_damage = damage
	_reach = reach
	_attack_rate = attack_rate
	_aggro_range = aggro_range
	_d_timer = death_timer
	_summoner_id = summoner_id
	default_attribute = {"speed": speed, "health": health, "damage": damage}


func _physics_process(delta):
	#other_bodies = get_tree().get_nodes_in_group("minions")
	#other_bodies.remove( other_bodies.find( self ) )
	#print( "Found ", other_bodies.size() )
	# if the minion has not locked onto an enemy yet, check if one is in range
	if not aggro_target:
		aggro_target = choose_target()
	## DETERMINE IF MOVING TOWARDS FINAL DESTINATION (OFF SCREEN) OR TOWARDS A TARGETTED ENEMY
	## -----------------------
	# check if enemy has been identified
	chase_force = steering_control.steering( position, path[0], vel, delta )
	if has_target():
		_going_towards = aggro_target.get_ref().position
		chase_force = steering_control.steering( position, _going_towards, vel, delta )
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
		#var bound_force = steering_control.rect_bound( position, vel, Rect2( Vector2( 0, 0 ), Vector2( 1024, 930 ) ).size, 20, 20, delta )
		var other_pos = []
		var other_vel = []
		
		#for o in other_bodies:
		#	other_pos.append( o.position )
		#	other_vel.append( o.vel )
			
		flockforce = steering_control.flocking( position, vel, other_pos, other_vel, \
				40, 60, \
				50, 1, \
				50, 1)
		force = chase_force  + flockforce
		force = steering_control.truncate( force, steering_control.max_force )
		vel += force * delta
		steering_control.max_vel = _speed
		vel = steering_control.truncate( vel, steering_control.max_vel )

		motion = vel * delta
		position = ( position + motion )
		
		#print( chase_force, " ", flockforce )
		# Rotate minion to face where it is going
		look_at(path[0])
		#print(path)
		# If we are still too far from the next step, continue to head towards it
		if dist_step > 75:
			move_and_slide(motion)
		# If we have reached this step, remove it, so the next step is bumped up in line
		else:
			if path.size() > 1:
				path.remove(0)
	# If the final destination's distance is within the minion's reach, start attacking it
	else:
		if not attacking:
			reached_goal()
	## -----------------------

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
			if (not has_target() and not enemy.has_target()) or (aggro_target and nearer(enemy, aggro_target.get_ref()) and not enemy.has_target()):
				aggro_target = weakref(enemy)
	return aggro_target


func reached_goal():
	if path.size() == 1 and not has_target():
		# If we have reached the final destination, off screen, then despawn minion...
		_die()
	else:
		# ... otherwise, if we have reached an enemey target instead, start attacking them
		attacking = true
		attack_timer.set_wait_time(_attack_rate)
		attack_timer.start()
		

func _die():
	# Mob has died
	# TODO: explosion / death animation
	queue_free()


func _on_AttackTimer_timeout():
	# attacks goal on timeout
	if has_target() and position.distance_to(aggro_target.get_ref().position) <= _reach:
		# FIGHT TIME!
		aggro_target.get_ref().take_damage(_damage)


func _on_DeathTimer_timeout():
	_die()
