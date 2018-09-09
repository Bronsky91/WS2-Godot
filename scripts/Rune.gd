extends Area2D

export(PackedScene) var fireball
var target = null
var new_fireball = null

func _ready():
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exit")

func _process(delta):
	if target and new_fireball == null:
		_shoot()
		

func _on_area_entered(enemy):
	target = enemy
	print('penatrated')
	print(target.name)


func _on_area_exited(enemy):
	target = null
	
func _shoot():
	print('FIREBALL')
	new_fireball = fireball.instance()
	new_fireball.target = target
	new_fireball.position = global_position
	get_tree().get_root().add_child(new_fireball)
	