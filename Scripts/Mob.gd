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
var velocity = Vector2()
var ahead = Vector2()
var ahead2 = Vector2()
const MAX_AVOID_FORCE = 200
const MAX_SEE_AHEAD = 50
var force = Vector2()
var other_bodies = []
var vel = Vector2()

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
	path = nav.get_simple_path(self.position, _goal, false)
	if path.size() == 0: 
		print('goal reached')
		reached_goal()


func update_path_aggro(_goal):
	if path.size() > 1:
		path[path.size() - 1] = _goal

   
func avoid_collision():
	var most_threatening = find_obstacle()
	var avoidance = Vector2()
	if most_threatening != null:
		avoidance.x = ahead.x - most_threatening.position.x
		avoidance.y = ahead.y - most_threatening.position.y
		avoidance = avoidance.normalized()
		avoidance = avoidance * MAX_AVOID_FORCE
	else:
		avoidance = avoidance * 0
	return avoidance


func find_obstacle():
	var most_threatening = null
	var other_bodies = get_tree().get_nodes_in_group("enemies") + get_tree().get_nodes_in_group("minions")
	other_bodies.remove(other_bodies.find(self))
	for mob in other_bodies:
		var shape = mob.collider
		var collision = intersecting(ahead, ahead2, shape)
		if collision and (most_threatening == null or position.distance_to(shape.position) < position.distance_to(most_threatening.position)):
			most_threatening = shape
	return most_threatening


func intersecting(ahead, ahead2, shape):
	return shape.position.distance_to(ahead) <= shape.shape.radius || shape.position.distance_to(ahead2) <= shape.shape.radius;


func take_damage(damage):
	# Mob has taken damage
	_health -= damage
	if _health <= 0:
		_die()


func remove_debuffs():
	# If debuffs affected enemy speed or damage they are now reset
	_speed = default_attribute.speed
	_damage = default_attribute.damage