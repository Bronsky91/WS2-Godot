extends Node2D

onready var global = get_node("/root/Global")
onready var enemy_timer = $EnemyTimer
onready var start_timer = $StartTimer
onready var message = $CanvasLayer/Message

var nav
var tower

var level
var level_scene
var spawn_new = false
var waves_over = false
var current_wave = 0
var current_enemy_batch = 0
var current_enemy = 0
var enemy_quantity = 0
var spawn_points = []

export(PackedScene) var enemy
export(PackedScene) var nav_point


func _ready():
	Sound.get_node("Main").stop()
	#Sound.get_node("Battle").play()
	# Loads level fom JSON file and sets UI bars
	_load_level("TD%04d" % global.level_state.current)
	global.game = weakref(self)
	global.mana_bar(global.mana)
	global.hp_bar(global.base_hp)


func _process(delta):
	# Checks when to spawn the next enemy
	if spawn_new and not waves_over:
		_process_enemy()
	elif waves_over and get_tree().get_nodes_in_group("enemies").size() == 0:
	# Ends the level when all enemies are off the map and no more waves incoming
		global.level_state.completed.append(global.level_state.current) # Advances tp next level
		global.level_state.remaining.remove(global.level_state.remaining.find(global.level_state.current))
		global.level_state.current = global.level_state.remaining[0]
		global.end_level = true
		global.clear_map()
		get_tree().change_scene("res://Scenes/LevelSelection.tscn") # Brings to level complete scene


func _load_level(levelname):
	level_scene = load("res://Scenes/LevelsTD/" + levelname + ".tscn")
	var scene_instance = level_scene.instance()
	get_node("Level").add_child(scene_instance)
	nav = get_node("Level/TowerDefenseLevel/Nav")
	tower = get_node("Level/TowerDefenseLevel/Tower")
	global.start_points = []
	global.end_level = false
	var file = File.new()
	file.open("res://Config/Levels/" + levelname + ".json", File.READ)
	var text = file.get_as_text()
	level = JSON.parse(text).result
	print("spawn_points count: " + str(spawn_points.size()))
	for s in get_node("Level/TowerDefenseLevel/SpawnPoints").get_children():
		spawn_points.append(s)
		global.start_points.append(s.position)
	# Begins level
	message.show()
	start_timer.set_wait_time(level.waves[0].start_timer)
	start_timer.start()


func _process_enemy():
	# Processes the enemy then starts timer for next enemy
	_spawn_enemy(level.waves[current_wave].enemies[current_enemy_batch])
	spawn_new = false
	enemy_timer.set_wait_time(level.waves[current_wave].enemies[current_enemy_batch].enemy_timer)
	enemy_timer.start()


func _spawn_enemy(d):
	# instances enemy into map and sets nav goal to base
	var new_enemy = enemy.instance()
	new_enemy.init(d.sprite ,d.speed, d.health, d.damage, d.reach, d.attack_rate)
	for s in spawn_points:
		if s.name == d.path:
			new_enemy.position = s.position
	new_enemy.final_dest = tower.position
	new_enemy.nav = nav
	global.nav = nav
	add_child(new_enemy)


func _increment_enemy():
	current_enemy += 1
	if current_enemy > level["waves"][current_wave]["enemies"][current_enemy_batch].quantity - 1:
		current_enemy = 0
		current_enemy_batch += 1
		if current_enemy_batch > level["waves"][current_wave]["enemies"].size() - 1:
			current_enemy_batch = 0
			current_wave += 1
			if current_wave < level["waves"].size():
				start_timer.set_wait_time(level.waves[current_wave].start_timer)
				start_timer.start()
				message.show()
				enemy_timer.stop()
			else:
				current_wave = 0
				waves_over = true
				enemy_timer.stop()


func _on_EnemyTimer_timeout():
	_increment_enemy()
	if not start_timer.is_stopped():
		spawn_new = false
	elif not waves_over:
		spawn_new = true
		

func _on_StartTimer_timeout():
	spawn_new = true
	print('start!')
	message.hide()
	start_timer.stop()


