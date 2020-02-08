extends KinematicBody2D

var steering_control = preload( "res://Scripts/Steering.gd" ).new()

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
var last_attr = {
	"speed": 0,
	"damage": 0,
}

var force = Vector2()
var other_bodies = []
var vel = Vector2()
var chase_force = Vector2()
var flockforce
var motion = Vector2()

onready var attack_timer = $AttackTimer
onready var global = get_node("/root/Global")
onready var collider = $CollisionShape2D

func _ready():
	steering_control 
	steering_control.max_vel = _speed
	steering_control.max_force = 1500
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
	print(_goal)
	path = nav.get_simple_path(self.position, _goal, false)
	print(path)
	if path.size() == 0: 
		call("reached_goal")

func update_path_aggro(_goal):
	if path.size() > 1:
		path[path.size() - 1] = _goal

func take_damage(damage):
	# Mob has taken damage
	_health -= damage
	if _health <= 0:
		call("_die")

func remove_debuffs(d):
	# If debuffs affected enemy speed or damage they are now reset
	var reset_value = d.value * d.duration
	if d.attribute == "speed":
		if d.operand == 'subtract':
			_speed += reset_value 
		elif d.operand == 'add':
			_speed -= reset_value
		elif d.operand == 'divide':
			_speed *= reset_value
		elif d.operand == 'multiply':
			if reset_value == 0:
				_speed = last_attr.speed
			else:
				_speed /= reset_value
