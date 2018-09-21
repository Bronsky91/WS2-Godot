extends RigidBody2D

# class member variables go here, for example:
const SPEED = 200
export var health = 125


func _ready():
	add_to_group("enemies")
	set_physics_process(true)

func _physics_process(delta):
	#if health <= 0:
		#if dead_since > global.DEAD_CLEAN_INTVAL:
		#	queue_free()
		#else:
		#	dead_since += delta
		#return
		
	if get_parent().get_unit_offset() < 1.0:
		get_parent().set_offset(get_parent().get_offset() + (SPEED * delta) )
	else:
		print(get_name() + " reached harry potter's house")
		queue_free()
		#global.hit_fortress(damage)

func take_damage(damage):
	print("TAKING DAMAGE")
	global = get_node("/root/global")
	health -= damage
	if health <= 0:
		_die()

func _die():
	print("DEAD")
	# explosion / death animation
	queue_free()