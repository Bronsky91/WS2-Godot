extends RigidBody2D

# class member variables go here, for example:
var _speed
var _health
var _damage
var nav = null setget set_nav
var path = []
var goal = Vector2()

var afflicted = false
var next_affliction_cycle = false
var affliction_counter = 0
var affliction_max = 0
var debuff_details

onready var debuff_timer = $DebuffTimer 
onready var global = get_node("/root/Global")


func _ready():
	print("I'm alive!")
	add_to_group("enemies")
	set_physics_process(true)


func init(sprite, speed, health, damage):
	get_node("Sprite").set_texture(load("res://Assets/" + sprite + ".png"))
	_speed =  speed
	_health = health
	_damage = damage


func _physics_process(delta):
	if path.size() > 1:
		var dist = self.position.distance_to(path[0])
		if dist > 2:
			# close to Harry Potter's house
			self.position = self.position.linear_interpolate(path[0], (_speed * delta)/dist)
		else:
			path.remove(0)
	else:
		print("_fixed_process() reached_tower")
		reached_tower()
		
	if afflicted and next_affliction_cycle:
		debuff_stack(debuff_details)
		
		
func set_nav(new_nav):
	nav = new_nav
	update_path()
	
func update_path():
	path = nav.get_simple_path(self.position, goal, false)
	if path.size() == 0:
		print("update_path() reached_tower")
		reached_tower()

func reached_tower():
	print(get_name() + " reached harry potter's house")
	queue_free()
	global.hit_base(_damage)

func take_damage(damage):
	_health -= damage
	if _health <= 0:
		_die()


func _die():
	# explosion / death animation
	print("I died")
	queue_free()
	
	
func debuff_stack(debuff_array):
	for debuff in debuff_array:
		affliction_max = debuff["duration"]
		if debuff["reoccuring"] > 0:
			debuff_timer.set_wait_time(debuff["reoccuring"])
			debuff_timer.start()
		next_affliction_cycle = false
		# The code below brought to you buy GDScript..
		if debuff["operand"] == "subtract":
			if debuff["field"] == "health":
				take_damage(debuff["value"])
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
		next_affliction_cycle = true
	else:
		afflicted = false
		affliction_counter = 0
		debuff_timer.stop()
		