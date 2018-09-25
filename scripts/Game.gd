extends Node

onready var global = get_node("/root/Global")
onready var wave_timer = $Timer
export var number_of_waves = 6
var new_wave = false
var wave_counter = 0
export(PackedScene) var enemy


func _ready():
	#if global.restart:
		#get_tree().reload_current_scene()
	wave_timer.stop()
	global.game = self


func _process(delta):
	if new_wave:
		_begin_wave(randi()%2+1, rand_range(.1,.5))
		

func _begin_wave(path_num, set_timer):
	# path_num is the path number the enemy will spawn on and follow
	# set_timer sets the time between enemy waves
	_spawn_enemy(enemy,"Path" + str(path_num))
	new_wave = false
	wave_timer.set_wait_time(set_timer)
	wave_timer.start()
	

func _spawn_enemy(type,path):
	var new_enemy = type.instance()
	new_enemy.init("Enemy",200,125,20)
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
