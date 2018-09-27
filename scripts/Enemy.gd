extends RigidBody2D

# class member variables go here, for example:
var _speed
var _health
var _damage

var afflicted = false
var affliction_rate = false
var affliction_counter = 0
var affliction_max = 0
var debuff_details

onready var debuff_timer = $DebuffTimer 
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
	if afflicted and affliction_rate:
		debuff_stack(debuff_details)
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
	
	
func debuff_stack(debuff_array):
	for debuff in debuff_array:
		affliction_max = debuff["duration"]
		if debuff["reoccuring"] > 0:
			debuff_timer.set_wait_time(debuff["reoccuring"])
			debuff_timer.start()
		affliction_rate = false
		# The code below brought to you buy GDScript..
		if debuff["operand"] == "subtract":
			if debuff["field"] == "health":
				print(_health)
				take_damage(debuff["value"])
				print(_health)
			elif debuff["field"] == "speed" and _speed > debuff["value"]:
				_speed -= debuff["value"]
			elif debuff["field"] == "damage" and _damage > debuff["value"]:
				_damage -= debuff["value"]
		elif debuff["operand"] == "add":
			if debuff["field"] == "health":
				_health += debuff["value"]
			elif debuff["field"] == "speed":
				_speed += debuff["value"]
			elif debuff["field"] == "damage":
				_damage += debuff["value"]
		elif debuff["operand"] == "multiply":
			if debuff["field"] == "health":
				_health *= debuff["value"]
			elif debuff["field"] == "speed":
				_speed *= debuff["value"]
			elif debuff["field"] == "damage":
				_damage *= debuff["value"]
		elif debuff["operand"] == "divide":
			if debuff["field"] == "health":
				_health /= debuff["value"]
			elif debuff["field"] == "speed" and _speed > debuff["value"]:
				_speed /= debuff["value"]
			elif debuff["field"] == "damage" and _damage > debuff["value"]:
				_damage /= debuff["value"]
	

func _on_DebuffTimer_timeout():
	# calls debuff stack function
	if affliction_counter <= affliction_max:
		affliction_counter += 1
		affliction_rate = true
	else:
		afflicted = false
		affliction_counter = 0
		debuff_timer.stop()
		