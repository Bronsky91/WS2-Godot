extends Node

onready var global = get_node("/root/Global")
onready var wave_timer = $Timer
export var number_of_waves = 6
var new_wave = false
var wave_counter = 0
export(PackedScene) var enemy

func _ready():
	global.game = self


func _process(delta):
	if new_wave:
		_begin_wave()
		

func _begin_wave():
	_spawn_enemy(enemy,"Path1")
	_spawn_enemy(enemy,"Path2")
	new_wave = false
	wave_timer.start()
	

func _spawn_enemy(type,path):
	var new_enemy = type.instance()
	var pathFollow = PathFollow2D.new()
	pathFollow.set_loop(false)
	self.get_node(path).add_child(pathFollow)
	pathFollow.add_child(new_enemy)


func _on_Timer_timeout():
	wave_counter += 1
	if wave_counter <= number_of_waves:
		new_wave = true
	else:
		new_wave = false
