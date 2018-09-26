extends Node2D

export(PackedScene) var spell

var _attack_range
var _fire_delta
var _damage
var _speed
var _spell_sprite

var fire_next = 0.0
var target = null
var spell_scale
var firing = false
var time = 0.0



func _ready():
	pass


func init(rune_details):
	get_node("Sprite").set_texture(load("res://Assets/" + rune_details["rune_sprite"] + ".png"))
	_speed =  rune_details["speed"]
	_attack_range = rune_details["attack_range"]
	_fire_delta = rune_details["fire_delta"]
	_damage = rune_details["damage"]
	_spell_sprite = rune_details["spell_sprite"]
	

func _process(delta):
	time += delta #
	var target = choose_target()
	if target != null and !firing:
		_shoot(target)


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
	if time > fire_next:
		firing = true
		var new_spell = spell.instance()
		new_spell.get_node("Sprite").set_texture(load("res://Assets/" + _spell_sprite + ".png"))
		new_spell.set_scale(spell_scale)
		new_spell.target = target
		new_spell.rune = weakref(self)
		new_spell.position = global_position
		fire_next = time + _fire_delta
		get_tree().get_root().add_child(new_spell)


func rearm():
	firing = false
	
	
	