extends Area2D

export(PackedScene) var fireball
var target = null
var firing = false
var time = 0.0
var fire_delta = 1.0/2.0
var fire_next = 0.0

func _ready():
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")

func _process(delta):
	time += delta #
	if target and target.get_ref() and !firing:
		_shoot()

func _on_area_entered(collidee):
	if collidee.name == "Enemy":
		target = weakref(collidee)
		
func _on_area_exited(collidee):
	if collidee.name == "Enemy":
		target = null

func rearm():
	firing = false
	
func _shoot():
	if time > fire_next:
		print('FIREBALL')
		firing = true
		var new_fireball = fireball.instance()
		new_fireball.target = target
		new_fireball.rune = weakref(self)
		new_fireball.position = global_position
		fire_next = time + fire_delta
		get_tree().get_root().add_child(new_fireball)

