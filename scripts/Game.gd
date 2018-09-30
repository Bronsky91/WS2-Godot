extends Node2D

onready var global = get_node("/root/Global")
onready var wave_timer = $Timer
onready var path_end = get_node("PathEnd").position
onready var nav = get_node("Nav")
onready var map = get_node("Nav/TileMap")

var waves
var spawn_new = false
var waves_over = false
var current_wave = 0
var current_enemy_batch = 0
var current_enemy = 0
var enemy_quantity = 0
var mouse_pos
export(PackedScene) var enemy


func _ready():
	_load_level("Level" + str(global.current_level))
	global.game = self
	global.mana_bar(global.mana)
	global.hp_bar(global.base_hp)


func _process(delta):
	if spawn_new and not waves_over:
		_process_wave()
	elif waves_over and get_tree().get_nodes_in_group("enemies").size() == 0:
		global.current_level += 1
		get_tree().change_scene("res://scenes/LevelComplete.tscn")
		
	mouse_pos = get_global_mouse_position()
	global.cursor_tile_x = int(mouse_pos.x) / global.TILE_WIDTH
	global.cursor_tile_y = int(mouse_pos.y) / global.TILE_HEIGHT
	global.cursor_tile_pos = Vector2(
		(global.cursor_tile_x * 64) + (global.TILE_WIDTH / 2),
		(global.cursor_tile_y * 64) + (global.TILE_HEIGHT / 2)
	)

	print("global: " + str(global.cursor_tile_pos) + " -- mouse: " + str(mouse_pos))
		
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
	new_enemy.position = get_node(d.path).position
	new_enemy.goal = path_end
	new_enemy.nav = nav
	add_child(new_enemy)
	#connect("map_update", new_enemy, "update_path")
	
	#var pathFollow = PathFollow2D.new()
	#pathFollow.set_loop(false)
	#self.get_node(d.path).add_child(pathFollow)
	#pathFollow.add_child(new_enemy)
	

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
		
