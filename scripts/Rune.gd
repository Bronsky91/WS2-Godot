extends Area2D

export(PackedScene) var fireball
var target = null
var firing = false

func _ready():
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exit")

func _process(delta):
	if target and target.get_ref() and !firing:
		_shoot()

func _on_area_entered(collidee):
	if collidee.name == "Enemy":
		target = weakref(collidee)
		print('penatrated')
		print(target.get_ref().name)

func rearm():
	print("RUNE FIRING = FALSE")
	firing = false

func _on_area_exited(enemy):
	target = null
	
func _shoot():
	print('FIREBALL')
	firing = true
	var new_fireball = fireball.instance()
	new_fireball.target = target
	new_fireball.rune = weakref(self)
	new_fireball.position = global_position
	get_tree().get_root().add_child(new_fireball)
	