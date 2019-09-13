extends "Rune.gd"

onready var spell = load("res://Scenes/Spell.tscn")

var direction = Vector2(0, -1)
var rune = null

func _ready():
	pass


func _process(delta):
	pass


func init(d):
	_range = d["range"]
	_speed =  d["speed"]
	_pulse = d["pulse"]
	_chaining = d["chaining"]
	_damage = d["damage"]
	_spell_sprite = d["spell_sprite"]
	_debuffs = d["debuffs"]
	if _chaining:
		_chain_counter = d["chain_counter"]
		_chain_range = d["chain_range"]
		_chain_max = d["chain_max"]
		_targets_hit = d["targets_hit"]
	
func _physics_process(delta):
	if target and target.get_ref():
	# If enemy is not null and an enemy is found within range
		var pos = get_global_position()
		if target.get_ref().get_global_position().distance_to(get_global_position()) < 10:
		# If enemy is in range spell follows and hit
			target_hit(_damage)
			return
		# logic to have spell rotate to face enemy while in route
		# TODO: Refactor to just look_at()?
		direction = (target.get_ref().get_global_position() - pos).normalized()
		var rad_angle = atan2(-direction.x, direction.y)
		set_rotation(rad_angle)
		set_position(pos + (direction * _speed * delta))
	else:
		# TODO: special animation or behavior for fireball whose target dies before reaching it?
		# TODO: extra logic to account for runes that may be destroyed before this part of the spell code is executed
		queue_free()


func target_hit(damage):
	var last_target = target.get_ref()
	# If the target as not been hit, append the target into targets hit
	if _targets_hit.find(last_target) == -1:
		last_target.take_damage(damage) # Enemy takes damage
		_targets_hit.append(last_target)
	# TODO: extra logic to account for runes that may be destroyed before this part of the spell code is executed
	#if rune.get_ref():
		#rune.get_ref().rearm() # Rearms rune to fire again once enemy is hite
	
	if _debuffs:
	# if the rune has the debuff attribute
		for debuff in _debuffs:
			if not target.get_ref().afflictions.has(debuff["name"]):
			# If the enemy is not already afflicted with the current debuff class of the spell
				apply_debuff(debuff, target)
	var global = get_node("/root/Global")
	if _chaining:
		var new_target = choose_target()
		if new_target != null and _targets_hit.find(new_target.get_ref()) == -1 and _chain_counter < _chain_max:
			_chain_counter += 1
			_shoot(new_target, spell, last_target.position, _chain_counter, _targets_hit)
	# Increases ultimate charge
	global.increase_ult_charge(damage)
	queue_free()

