extends Area2D

export(PackedScene) var fireball
var firing = false
var attack_range = 300
var time = 0.0
var fire_delta = 1.0/3.0
var fire_next = 0.0

func _ready():
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")

func _process(delta):
	time += delta #
	var target = choose_target()
	if target != null and !firing:
		_shoot(target)

func _on_area_entered(collidee):
	if collidee.name == "Enemy":
		print('penatrated')

func _on_area_exited(collidee):
	#if collidee.name == "Enemy":
	#	for i in range(targets.size() -1, 0, -1):
	#		if targets[i] and targets[i].get_ref() and collidee.get_id() == targets[i].get_ref().get_id():
	#			targets.remove(i)
	pass

func choose_target():
	var target = null
	var pos = get_global_position()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		#print("distance: " + str(pos.distance_to(enemy.get_global_position())))
		if pos.distance_to(enemy.get_global_position()) <= attack_range:
			if target == null or pos.distance_to(enemy.get_global_position()) > get_global_position().distance_to(target.get_global_position()):
				target = weakref(enemy)
	return target
	
	
func _shoot(target):
	if time > fire_next:
		print('FIREBALL')
		firing = true
		var new_fireball = fireball.instance()
		new_fireball.target = target
		new_fireball.rune = weakref(self)
		new_fireball.position = global_position
		fire_next = time + fire_delta
		get_tree().get_root().add_child(new_fireball)

func rearm():
	print("RUNE FIRING = FALSE")
	firing = false