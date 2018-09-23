extends RigidBody2D

# class member variables go here, for example:
var _speed = 200
var _health = 125
var _damage = 20
onready var global = get_node("/root/Global")


func _ready():
	add_to_group("enemies")
	set_physics_process(true)

func init(sprite, speed, health, damage):
	get_node("Sprite").set_texture(load("res://Assets/" + sprite + ".png"))
	_speed =  speed
	_health = health
	_damage = damage

func _physics_process(delta):
	#if health <= 0:
		#if dead_since > global.DEAD_CLEAN_INTVAL:
		#	queue_free()
		#else:
		#	dead_since += delta
		#return
		
	if get_parent().get_unit_offset() < 1.0:
		get_parent().set_offset(get_parent().get_offset() + (_speed * delta) )
	else:
		print(get_name() + " reached harry potter's house")
		queue_free()
		global.hit_base(_damage)
		

func take_damage(damage):
	_health -= damage
	if _health <= 0:
		_die()

func _die():
	# explosion / death animation
	queue_free()