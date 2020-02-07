extends Node2D

onready var global = get_node("/root/Global")
onready var start_timer = $StartTimer
onready var message = $CanvasLayer/Message
onready var cbutton = $CanvasLayer/CButton

var nav
var tower

var level
var level_scene
var waves_over = false
var current_wave = 0
var current_enemy_batch = 0
var current_enemy = 0
var enemy_quantity = 0
var spawn_points = []
var wave_process_done = false

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
	if get_tree().get_nodes_in_group("enemies").size() == 0 and wave_process_done:
		start_timer.set_wait_time(level.waves[current_wave].start_timer)
		start_timer.start()
		message.show()
	elif waves_over and get_tree().get_nodes_in_group("enemies").size() == 0 and not global.end_level:
	# Ends the level when all enemies are off the map and no more waves incoming
		global.level_state.completed.append(global.level_state.current) # Advances tp next level
		global.level_state.remaining.remove(global.level_state.remaining.find(global.level_state.current))
		global.level_state.current = global.level_state.remaining[0]
		global.end_level = true
		message.text = 'Awesome Show, Great Job!'
		message.show()
		cbutton.show()


func _load_level(levelname):
	level_scene = load("res://Scenes/LevelsTD/" + levelname + ".tscn")
	var scene_instance = level_scene.instance()
	global.level_size = calc_level_size( scene_instance.get_node("Nav/TileMap") )
	global.level_size.x *= global.TILE_WIDTH
	global.level_size.y *= global.TILE_HEIGHT
	get_node("Level").add_child(scene_instance)
	nav = get_node("Level/TowerDefenseLevel/Nav")
	tower = get_node("Level/TowerDefenseLevel/Tower")
	global.start_points = []
	global.end_level = false
	var file = File.new()
	file.open("res://Config/Levels/" + levelname + ".json", File.READ)
	var text = file.get_as_text()
	level = JSON.parse(text).result
	for s in get_node("Level/TowerDefenseLevel/SpawnPoints").get_children():
		spawn_points.append(s)
		global.start_points.append(s.position)
	# Begins level
	message.show()
	start_timer.set_wait_time(level.waves[0].start_timer)
	start_timer.start()


func calc_level_size(tilemap):
	var min_x = 0
	var max_x = 0
	var min_y = 0
	var max_y = 0
	var used_cells = tilemap.get_used_cells()
	for pos in used_cells:
		if pos.x < min_x:
			min_x = int(pos.x)
		elif pos.x > max_x:
			max_x = int(pos.x)
		if pos.y < min_y:
			min_y = int (pos.y)
		elif pos.y > max_y:
			max_y = int(pos.y)
	return Vector2(max_x + 1, max_y + 1)


func _spawn_enemy(d, type):
	# instances enemy into map and sets nav goal to base
	var new_enemy = enemy.instance()
	new_enemy.init(d.sprite ,d.speed, d.health, d.damage, d.reach, d.attack_rate)
	print('init')
	for s in spawn_points:
		print('s')
		if s.name == d.path:
			new_enemy.position = s.position
	new_enemy.final_dest = tower.position
	new_enemy.set_nav(nav)
	global.nav = nav
	print(global.nav)
	print('before add_child')
	add_child(new_enemy)
	print('add_child')
	_increment_enemy(type)


func _increment_enemy(type):
	current_enemy += 1
	if current_enemy > level["waves"][current_wave]["enemies"][type].quantity-1:
		current_enemy = 0
		if type == level["waves"][current_wave]["enemies"].size() - 1:
			current_wave += 1
			if current_wave < level["waves"].size():
				stop_enemy_timer(type)
				wave_process_done = true
			else:
				current_wave = 0
				waves_over = true
				stop_enemy_timer(type)


func stop_enemy_timer(type):
	get_node('enemy_timer_'+str(current_wave)+'_'+str(type)).stop()
	get_node('enemy_timer_'+str(current_wave)+'_'+str(type)).queue_free()


func on_Enemy_Timeout(enemy_type):
	# Checks when to spawn the next enemy
	if not waves_over:
		_spawn_enemy(level.waves[current_wave].enemies[enemy_type], enemy_type)


func _on_StartTimer_timeout():
	print('new wave?')
	wave_process_done = false
	message.hide()
	start_timer.stop()
	# Create and start timers
	for wave in level.waves.size():
		for enemy in level.waves[wave].enemies.size():
			var newTimerNode = Timer.new()
			newTimerNode.connect("timeout", self, "on_Enemy_Timeout", [enemy])
			newTimerNode.name = 'enemy_timer_'+str(wave)+'_'+str(enemy)
			newTimerNode.set_wait_time(level.waves[current_wave].enemies[enemy].enemy_timer)
			add_child(newTimerNode)
			if wave == 0:
				# If it's the first wave
				newTimerNode.start()


func _on_CButton_pressed():
		global.clear_map()
		get_tree().change_scene("res://Scenes/LevelSelection.tscn") # Brings to level complete scene
