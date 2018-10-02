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
var default_attribute

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
	default_attribute = {"speed": speed, "health": health, "damage": damage}
	

func _physics_process(delta):
	if path.size() > 1:
		var dist = self.position.distance_to(path[0])
		look_at(path[0])
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
	queue_free()
	
	
func debuff_stack(debuff_array):
	for debuff in debuff_array:
		affliction_max = debuff["duration"]
		if debuff["reoccuring"] > 0:
			debuff_timer.set_wait_time(debuff["reoccuring"])
			debuff_timer.start()
		next_affliction_cycle = false
		# The code below brought to you buy GDScript..
		_debuff_calculus(debuff["operand"], debuff["attribute"], debuff["value"])


func _debuff_calculus(op, attribute, value):
	if op == "subtract":
		if attribute == "health":
			take_damage(value)
		elif attribute == "speed" and _speed > value:
			_speed -= value
		elif attribute == "damage" and _damage > value:
			_damage -= value
	elif op == "add":
		if attribute == "health":
			_health += value
		elif attribute == "speed":
			_speed += value
		elif attribute == "damage":
			_damage += value
	elif op == "multiply":
		if attribute == "health":
			_health *= value
		elif attribute == "speed":
			_speed *= value
		elif attribute == "damage":
			_damage *= value
	elif op == "divide":
		if attribute == "health":
			_health /= value
		elif attribute == "speed" and _speed > value:
			_speed /= value
		elif attribute == "damage" and _damage > value:
			_damage /= value
			

func remove_debuffs():
	_speed = default_attribute.speed
	_damage = default_attribute.damage


func _on_DebuffTimer_timeout():
	# calls debuff stack function
	if affliction_counter <= affliction_max:
		affliction_counter += 1
		next_affliction_cycle = true
	else:
		afflicted = false
		affliction_counter = 0
		remove_debuffs()
		debuff_timer.stop()
		