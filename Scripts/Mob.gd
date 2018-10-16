extends RigidBody2D

# class member variables
var _speed
var _health
var _damage
var _reach
var _attack_rate
var _going_towards

var final_dest = Vector2()
var aggro_target = null
var encounter_start = false
var nav = null setget set_nav
var path = []
var afflictions = []
var default_attribute
var attacking = false

onready var attack_timer = $AttackTimer
onready var global = get_node("/root/Global")


func _ready():
	set_physics_process(true)


func has_target():
	return aggro_target and aggro_target.get_ref()


func nearer(a, b):
	var pos = get_global_position()
	var a_pos = a.get_global_position()
	var b_pos = b.get_global_position()
	return pos.distance_to(a_pos) > pos.distance_to(b_pos)


func fight_me(_aggro_target):
	aggro_target = _aggro_target


func set_nav(new_nav):
	nav = new_nav
	update_path(final_dest)


func update_path(_goal):
	path = nav.get_simple_path(self.position, _goal, false)
	if path.size() == 0: 
		print('goal reached')
		reached_goal()


func update_path_aggro(_goal):
	if path.size() > 1:
		path[path.size() - 1] = _goal

   
func take_damage(damage):
	# Mob has taken damage
	_health -= damage
	if _health <= 0:
		_die()


func remove_debuffs():
	# If debuffs affected enemy speed or damage they are now reset
	_speed = default_attribute.speed
	_damage = default_attribute.damage