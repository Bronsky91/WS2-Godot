extends Node2D

onready var pulse_timer = $PulseTimer
onready var global = get_node("/root/Global")
onready var debuff_scene = load("res://Scenes/Debuff.tscn")
onready var particle_scene = load("res://Scenes/Particle.tscn")


# Sets class variables from init 
var _range
var _fire_delta
var _damage
var _speed
var _spell_sprite
var _particle
var _power_level
var _max_power_level
var _cost
var _debuffs
var _details
var _color
var _pulse
var _chaining
var _chain_range
var _chain_max
var _chain_counter = 0
var _targets_hit = []
var _placement
var _mob_stats
var _max_minions
var _targeting


var cursor_hovering = false
var fire_next = 0.0
var target = null
var spell_scale
var firing = false
var path_end
var summoned_minions = []

func _ready():
	add_to_group("runes")

func init(d):
	get_node("Sprite").set_texture(load("res://Assets/" + d["rune_sprite"] + ".png"))
	_placement = d["placement"]
	_color = d["rune_color"]
	_max_power_level = d["max_power_level"]
	_power_level = d["power_level"]
	_cost = d["cost"]
	_details = d
	modulate = Color(_color.r, _color.g, _color.b)
	_range = d["range"]
	_speed =  d["speed"]
	_pulse = d["pulse"]
	_chaining = d["chaining"]
	_fire_delta = d["fire_delta"]
	_damage = d["damage"]
	_spell_sprite = d["spell_sprite"]
	print(d)
	_particle = d["particle"]
	_debuffs = d["debuffs"]
	_mob_stats = d["mob"]
	if _chaining:
		_chain_range = d["chain_range"]
		_chain_max = d["chain_max"]

#func _process(delta):
#		time += delta #
#		target = choose_target()
#		if target != null and not firing:
#			_shoot(target)
#		if not firing and not global.end_level:
#			_summon(_mob)
			

func choose_target():
	var pos = get_global_position()
	
	# Check if existing target is still within range
	if not _chaining and target != null and target.get_ref() and pos.distance_to(target.get_ref().get_global_position()) <= _range:
		return target
	else:
		target = null
	
	# If not, check if new enemy is in range, and choose closest one if multiple
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if pos.distance_to(enemy.get_global_position()) <= _range:
			if (target == null 
				or !target.get_ref() 
				or pos.distance_to(enemy.get_global_position()) > get_global_position().distance_to(target.get_ref().get_global_position())):
					target = weakref(enemy)	
	return target


func _shoot(target, spell, chain_pos, _chain_counter, _targets_hit):
	# Creates spell and shoots at enemy target
	firing = true
	pulse_timer.set_wait_time(_pulse)
	pulse_timer.start()
	var new_spell = spell.instance()	
	new_spell.init({
			"damage": _damage,
			 "speed": _speed,
			 "debuffs": _debuffs,
			 "chaining": _chaining,
			 "chain_range": _chain_range,
			 "pulse": _pulse,
			 "spell_sprite": _spell_sprite,
			 "range": _range,
			 "chain_max": _chain_max,
			 "chain_counter": _chain_counter, # DON'T LOOK SSHHHHHHHhhhh
			 "targets_hit": _targets_hit
		})
	new_spell.get_node("Sprite").set_texture(load("res://Assets/" + _spell_sprite + ".png"))
	#new_spell.set_scale(spell_scale)
	new_spell.target = target
	new_spell.rune = weakref(self)
	new_spell.position = chain_pos
	var particle = particle_scene.instance()
	print(particle)
	particle.init(_particle)
	print(particle)
	new_spell.add_child(particle)
	get_tree().get_root().add_child(new_spell)
	
	
func minions_this_rune_summoned(group):
	var owned_minions = []
	for minion in group:
		if minion._summoner_id == self.get_instance_id():
			owned_minions.append(minion.get_instance_id())
	return owned_minions
	

func _summon(minion, d, pos):
	if minions_this_rune_summoned(get_tree().get_nodes_in_group('minions')).size() < d.max_quantity:
		pulse_timer.set_wait_time(d.summon_rate)
		pulse_timer.start()
		firing = true
		for i in range(d.summon_quantity, 0, -1):
			var new_minion = minion.instance()
			new_minion.init(d.sprite ,d.speed, d.health, d.damage, d.reach, d.attack_rate, d.aggro_range, d.death_timer, self.get_instance_id())
			new_minion.position = pos
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
	if _damage:
		_damage *= 1.0 + (_power_level / 10)
	global.mana_bar(global.mana)
	# TODO: Find a way to include fire rate delta and speed of spell without breaking game
	#_fire_delta = 1.0/(power - 10)
	#_speed *= 1.0 - (power / 10)
	#set_scale(Vector2(_power_level, _power_level))
	modulate = Color(_color.r / _power_level, _color.g / _power_level, _color.b / _power_level)
	spell_scale = Vector2(_power_level, _power_level)


func apply_debuff(debuff, target):
	# Applies debuff that is this spell uses
	target.get_ref().afflictions.append(debuff["name"])
	var new_debuff
	new_debuff = debuff_scene.instance()
	# adds the debuff as a child of the enemy so multiple can be applied
	target.get_ref().add_child(new_debuff)
	new_debuff.init(debuff)
	
	
func _input(event):
	# Watches for if player is scrolling over runes to power them up or down
	if cursor_hovering and event.is_action_released("power_up") and _power_level < _max_power_level and global.mana > _cost:
		power_up()
		print('powering up')
	if cursor_hovering and event.is_action_released("power_down") and _power_level > 1 and global.mana < global.mana_max:
		power_down()
		print('powering down')
	if cursor_hovering and event.is_action_released("remove"):
		global.mana += _cost # Refund full cost for now when destroying rune
		#TODO: Make cooldown (probably long) of how often you can destroy a rune and refund
		global.mana_bar(global.mana)
		queue_free()
		# When the rune is freed the mouse never gets a chance to leave the rune to place the exiting variables back to false
		global.hovering_on_any_rune = false
		cursor_hovering = false


func _on_PulseTimer_timeout():
	rearm()
	
