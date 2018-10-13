extends RigidBody2D

# class member variables
var _speed
var _health
var _damage
var _reach
var _attack_rate
var _is_minion

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


func init(sprite, speed, health, damage, reach, attack_rate, is_minion):
	get_node("Sprite").set_texture(load("res://Assets/" + sprite + ".png"))
	_speed =  speed
	_health = health
	_damage = damage
	_reach = reach
	_attack_rate = attack_rate
	_is_minion = is_minion
	default_attribute = {"speed": speed, "health": health, "damage": damage}
	

func _physics_process(delta):
	# Lets enemy follow nav path tiles
	if path.size() > _reach and not attacking:
		var dist = self.position.distance_to(path[0])
		look_at(path[0])
		if dist > 2:
			self.position = self.position.linear_interpolate(path[0], (_speed * delta)/dist)
		else:
			path.remove(0)
	else:
		if not attacking:
			reached_goal()
			
		
		
func set_nav(new_nav):
	nav = new_nav
	update_path()
	
	
func update_path():
	path = nav.get_simple_path(self.position, goal, false)
	if path.size() == 0:
		reached_goal()


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
	if _is_minion:
		# attack target
		# FIGHT TIME!
		pass
	else:
		global.hit_base(_damage)
		print(get_name() + " attacking harry potter's house")
