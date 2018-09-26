extends Node

onready var global = get_node("/root/Global")
onready var wave_timer = $Timer
var waves
var spawn_new = false
var waves_over = false
var current_wave = 0
var current_enemy_batch = 0
var current_enemy = 0
var enemy_quantity = 0
export(PackedScene) var enemy


func _ready():
	#if global.restart:
		#get_tree().reload_current_scene()
	#wave_timer.stop()
	_load_level("Level0001")
	global.game = self


func _process(delta):
	if spawn_new and not waves_over:
		_process_wave()
	elif waves_over and get_tree().get_nodes_in_group("enemies").size() == 0:
		get_tree().change_scene("res://scenes/LevelComplete.tscn")
		
		
func _load_level(level):
	var file = File.new()
	file.open("res://config/levels/" + level + ".json", File.READ)
	var text = file.get_as_text()
	waves = JSON.parse(text).result
	if (waves["waves"].size() > 0):
		spawn_new = true
	
	
func _process_wave():
	_spawn_enemy(waves["waves"][current_wave]["enemies"][current_enemy_batch])
	spawn_new = false
	wave_timer.set_wait_time(waves["waves"][current_wave]["enemies"][current_enemy_batch].enemy_timer)
	wave_timer.start()
	
	
func _spawn_enemy(d):
	var new_enemy = enemy.instance()
	new_enemy.init(d.sprite ,d.speed,d.health,d.damage)
	var pathFollow = PathFollow2D.new()
	pathFollow.set_loop(false)
	self.get_node(d.path).add_child(pathFollow)
	pathFollow.add_child(new_enemy)
	

func _increment_enemy():
	current_enemy += 1
	if(current_enemy > waves["waves"][current_wave]["enemies"][current_enemy_batch].quantity - 1):
		current_enemy = 0
		current_enemy_batch += 1
		if(current_enemy_batch > waves["waves"][current_wave]["enemies"].size() - 1):
			current_enemy_batch = 0
			current_wave += 1
			if(current_wave > waves["waves"].size() - 1):
				current_wave = 0
				waves_over = true
				wave_timer.stop()


func _on_Timer_timeout():
	_increment_enemy()
	if not waves_over:
		spawn_new = true
		


		