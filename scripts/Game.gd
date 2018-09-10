extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export(PackedScene) var enemy

func _ready():
	_begin_wave()

func _begin_wave():
	_spawn_enemy(enemy,"Path1")
	_spawn_enemy(enemy,"Path2")
	

func _spawn_enemy(type,path):
	var new_enemy = type.instance()
	var pathFollow = PathFollow2D.new()
	pathFollow.set_loop(false)
	self.get_node(path).add_child(pathFollow)
	pathFollow.add_child(new_enemy)