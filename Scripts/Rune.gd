extends Node2D

export(PackedScene) var spell
export(PackedScene) var minion

onready var summon_timer = $SummonTimer
onready var global = get_node("/root/Global")

# Sets class variables from init 
var _attack_range
var _fire_delta
var _damage
var _speed
var _spell_sprite
var _power_level
var _max_power_level
var _cost
var _debuffs
var _details
var _color
var _rune_class
var _mob_stats
var _max_minions

var cursor_hovering = false
var fire_next = 0.0
var target = null
var spell_scale
var firing = false
var time = 0.0
var path_end
var summoned_minions = []


func _ready():
	add_to_group("runes")


func init(d, power_level):
	get_node("Sprite").set_texture(load("res://Assets/" + d["rune_sprite"] + ".png"))
	_rune_class = d["class"]
	_color = d["rune_color"]
	_max_power_level = d["max_power_level"]
	_power_level = power_level
	_cost = d["cost"]
	_details = d
	modulate = Color(_color.r, _color.g, _color.b)
	if _rune_class == "spell":
		_attack_range = d["attack_range"]
		_speed =  d["speed"]
		_fire_delta = d["fire_delta"]
		_damage = d["damage"]
		_spell_sprite = d["spell_sprite"]
		_debuffs = d["debuffs"]
	if _rune_class == "minion":
		_mob_stats = d["mob_stats"]
		

func _process(delta):
	if _rune_class == "spell":
		time += delta #
		target = choose_target()
		if target != null and not firing:
			_shoot(target)
	elif _rune_class == "minion":
		if not firing and not global.end_level:
			_summon(_mob_stats)
			

func choose_target():
	var pos = get_global_position()
	
	# Check if existing target is still within range
	if target != null and target.get_ref() and pos.distance_to(target.get_ref().get_global_position()) <= _attack_range:
		return target
	else:
		target = null
	
	# If not, check if new enemy is in range, and choose closest one if multiple
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if pos.distance_to(enemy.get_global_position()) <= _attack_range:
			if (target == null 
				or !target.get_ref() 
				or pos.distance_to(enemy.get_global_position()) > get_global_position().distance_to(target.get_ref().get_global_position())):
					target = weakref(enemy)	
	return target


func _shoot(target):
	# Creates spell and shoots at enemy target
	if time > fire_next:
		firing = true
		var new_spell = spell.instance()
		new_spell.init(_damage, _speed, _debuffs)
		new_spell.get_node("Sprite").set_texture(load("res://Assets/" + _spell_sprite + ".png"))
		new_spell.set_scale(spell_scale)
		new_spell.target = target
		new_spell.rune = weakref(self)
		new_spell.position = get_global_position()
		fire_next = time + _fire_delta
		get_tree().get_root().add_child(new_spell)
		
	
func minions_this_rune_summoned(group):
	var owned_minions = []
	for minion in group:
		if minion._summoner_id == self.get_instance_id():
			owned_minions.append(minion.get_instance_id())
	return owned_minions
	

func _summon(d):
	if minions_this_rune_summoned(get_tree().get_nodes_in_group('minions')).size() < d.max_quantity:
		summon_timer.set_wait_time(d.summon_rate)
		summon_timer.start()
		firing = true
		var new_minion = minion.instance()
		new_minion.init(d.sprite ,d.speed, d.health, d.damage, d.reach, d.attack_rate, d.aggro_range, self.get_instance_id())
		new_minion.position = get_global_position()
		new_minion.modulate = Color(0, 0, 1)
		path_end = global.find_closest_point(global.start_points, new_minion.position)
		new_minion.final_dest = path_end
		new_minion.nav = global.nav
		get_tree().get_root().add_child(new_minion)


func rearm():
	firing = false


func power_up():
	# increases power level of rune when scrolling up
	# removes mana based on power level
	_power_level += 1
	global.mana -= _cost
	refresh_rune()


func power_down():
	# decreases power level of rune when scrolling down
	# adds mana based on power level
	_power_level -= 1
	global.mana += _cost
	refresh_rune()


func refresh_rune():
	# gives rune updated stats based on current power level
	if _rune_class == "spell":
		_damage *= 1.0 + (_power_level / 10)
	global.mana_bar(global.mana)
	# TODO: Find a way to include fire rate delta and speed of spell without breaking game
	#_fire_delta = 1.0/(power - 10)
	#_speed *= 1.0 - (power / 10)
	#set_scale(Vector2(_power_level, _power_level))
	modulate = Color(_color.r / _power_level, _color.g / _power_level, _color.b / _power_level)
	spell_scale = Vector2(_power_level, _power_level)


func _input(event):
	# Watches for if player is scrolling over runes to power them up or down
	if event.is_pressed():
		if cursor_hovering and event.button_index == BUTTON_WHEEL_UP and _power_level < _max_power_level and global.mana > _cost:
			power_up()
		if cursor_hovering and event.button_index == BUTTON_WHEEL_DOWN and _power_level > 1 and global.mana < global.mana_max:
			power_down()
		if cursor_hovering and event.button_index == BUTTON_RIGHT:
			global.mana += _cost # Refund full cost for now when destroying rune
			#TODO: Make cooldown (probably long) of how often you can destroy a rune and refund
			global.mana_bar(global.mana)
			call_deferred('free')
			
			
func _on_Summon_Timer_timeout():
	rearm()

