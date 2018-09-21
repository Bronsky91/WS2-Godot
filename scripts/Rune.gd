extends Node2D

export(PackedScene) var spell
var firing = false
var attack_range = 300
var time = 0.0
var fire_delta = 1.0/2.0
var fire_next = 0.0
var target = null


func _ready():
	#connect("area_entered", self, "_on_area_entered")
	#connect("area_exited", self, "_on_area_exited")
	pass


func _process(delta):
	time += delta #
	var target = choose_target()
	if target != null and !firing:
		_shoot(target)


func choose_target():
	var pos = get_global_position()
	
	# Check if existing target is still within range
	if target != null and target.get_ref() and pos.distance_to(target.get_ref().get_global_position()) <= attack_range:
		return target
	else:
		target = null
	
	# If not, check if new enemy is in range, and choose closest one if multiple
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if pos.distance_to(enemy.get_global_position()) <= attack_range:
			if target == null or !target.get_ref() or pos.distance_to(enemy.get_global_position()) > get_global_position().distance_to(target.get_ref().get_global_position()):
				target = weakref(enemy)	
	return target
	
	
func _shoot(target):
	if time > fire_next:
		firing = true
		var new_spell = spell.instance()
		new_spell.target = target
		new_spell.rune = weakref(self)
		new_spell.position = global_position
		fire_next = time + fire_delta
		get_tree().get_root().add_child(new_spell)


func rearm():
	firing = false