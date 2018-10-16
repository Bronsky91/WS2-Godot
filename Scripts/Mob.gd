extends RigidBody2D

# class member variables
var _speed
var _health
var _damage
var _reach
var _attack_rate
var _is_minion
var _aggro_range
var _going_towards

var aggro_target = null
var nav = null setget set_nav
var path = []
var goal = Vector2()
var afflictions = []
var default_attribute
var attacking = false

onready var attack_timer = $AttackTimer
onready var global = get_node("/root/Global")


func _ready():
	if _is_minion:
		# Adding minions into 'minions' group
		add_to_group("minions")
	elif not _is_minion:
		# Adding enemies into 'enemies' group
		add_to_group("enemies")
	set_physics_process(true)


func init(sprite, speed, health, damage, reach, attack_rate, is_minion, aggro_range):
	get_node("Sprite").set_texture(load("res://Assets/" + sprite + ".png"))
	_speed =  speed
	_health = health
	_damage = damage
	_reach = reach
	_attack_rate = attack_rate
	_is_minion = is_minion
	_aggro_range = aggro_range
	default_attribute = {"speed": speed, "health": health, "damage": damage}
	

func _physics_process(delta):
	if _is_minion and not aggro_target:
		aggro_target = choose_target()
	if aggro_target and aggro_target.get_ref() and _going_towards != aggro_target.get_ref().get_global_position():
		_going_towards = aggro_target.get_ref().get_global_position()
		update_path(_going_towards)
		print('path size == '+str(path.size()) + ' and reach == '+str(_reach))
		if _is_minion:
			aggro_target.get_ref().fight_me(weakref(self))
	elif _going_towards != goal:
		attacking = false
		_going_towards = goal
		update_path(goal)
			
	# Lets enemy follow nav path tiles
	var total_dist = self.position.distance_to(_going_towards)
	var dist = self.position.distance_to(path[0])
	if total_dist > _reach and not attacking:
		look_at(path[0])
		if dist > 2:
			#if _is_minion and dist < 4:
			#	print('dist = '+str(dist))
			#	print('self.postion = '+str(self.position))
			#	print('new position? '+str(self.position.linear_interpolate(path[0], (_speed * delta)/dist)))
			self.position = self.position.linear_interpolate(path[0], (_speed * delta)/dist)
		else:
			path.remove(0)
	else:
		if not attacking:
			reached_goal()


func choose_target():
	var pos = get_global_position()
	
	# Check if existing target is still within range
	if aggro_target != null and aggro_target.get_ref() and pos.distance_to(aggro_target.get_ref().get_global_position()) <= _aggro_range:
		return aggro_target
	else:
		aggro_target = null
	
	# If not, check if new enemy is in range, and choose closest one if multiple
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if pos.distance_to(enemy.get_global_position()) <= _aggro_range:
			if (aggro_target == null 
				or !aggro_target.get_ref() 
				or pos.distance_to(enemy.get_global_position()) > get_global_position().distance_to(aggro_target.get_ref().get_global_position())):
					aggro_target = weakref(enemy)	
	return aggro_target
	
	
func fight_me(_aggro_target):
	aggro_target = _aggro_target


func set_nav(new_nav):
	nav = new_nav
	update_path(goal)


func update_path(_goal):
	path = nav.get_simple_path(self.position, _goal, false)
	if path.size() == 0: 
		print('goal reached')
		reached_goal()


#func update_path_aggro():
#	path = nav.get_simple_path(self.get_global_position(), aggro_target.get_ref().get_global_position(), false)
	

func reached_goal():
	# Called when enemy reaches base
	attacking = true
	attack_timer.set_wait_time(_attack_rate)
	attack_timer.start()
	 
   
func take_damage(damage):
	# Enemy has taken damage
	_health -= damage
	if _health <= 0:
		_die()
	

func _die():
	# explosion / death animation
	queue_free()
	

func remove_debuffs():
	# If debuffs affected enemy speed or damage they are now reset
	_speed = default_attribute.speed
	_damage = default_attribute.damage

		

func _on_AttackTimer_timeout():
	# attacks goal on timeout
	if aggro_target != null and aggro_target.get_ref() and get_global_position().distance_to(aggro_target.get_ref().get_global_position()) <= _reach:
		# FIGHT TIME!
		print('fight time?')
		aggro_target.get_ref().take_damage(_damage)
	else:
		global.hit_base(_damage)
		print(get_name() + " attacking harry potter's house")
