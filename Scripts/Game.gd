extends Node2D

onready var global = get_node("/root/Global")
onready var wave_timer = $WaveTimer
onready var path_end
onready var nav = get_node("Nav")
onready var map = get_node("Nav/TileMap")
onready var tower = get_node("Tower")

var level
var spawn_new = false
var waves_over = false
var current_wave = 0
var current_enemy_batch = 0
var current_enemy = 0
var enemy_quantity = 0

export(PackedScene) var enemy
export(PackedScene) var nav_point

func _ready():
	# Loads level fom JSON file and sets UI bars
	_load_level("Level" + str(global.current_level)) #TODO: Refactor level naming system for more customization
	global.game = weakref(self)
	global.mana_bar(global.mana)
	global.hp_bar(global.base_hp)


func _process(delta):
	# Checks when to spawn the next enemy
	if spawn_new and not waves_over:
		_process_wave()
	elif waves_over and get_tree().get_nodes_in_group("enemies").size() == 0:
	# Ends the level when all enemies are off the map and no more waves incoming
		global.current_level += 1 # Advances tp next level
		global.end_level = true
		for minion in get_tree().get_nodes_in_group('minions'):
			minion.queue_free()
		get_tree().change_scene("res://Scenes/LevelComplete.tscn") # Brings to level complete scene


func _load_level(levelname):
	global.end_level = false
	var file = File.new()
	file.open("res://Config/Levels/" + levelname + ".json", File.READ)
	var text = file.get_as_text()
	level = JSON.parse(text).result
	if level["tilemap"] != null:
		var c = 1
		for s in level["tilemap"]["startpoints"]:
			var new_startpoint = nav_point.instance()
			new_startpoint.position = global.get_tile_pos(s.x, s.y)
			new_startpoint.name = "Path" + str(c)
			global.start_points.append(new_startpoint.position)
			add_child(new_startpoint)
			c += 1
		path_end = global.get_tile_pos(level["tilemap"]["tower"].x,level["tilemap"]["tower"].y)
		tower.position = path_end
		var x = 0
		var y = 0
		for row in level["tilemap"]["tiles"]:
			for cell in row:
				#print("x: " + str(x) + ", y: " + str(y) + ", cell: " + str(cell))
				map.set_cell(x, y, cell)
				x += 1
			y += 1
			x = 0
		if level["waves"].size() > 0:
		# Begins level
		#TODO: Let player "start" level when they are ready or create a timer that the player sees
			spawn_new = true


func _process_wave():
	# Processes the wave of enemies then starts timer for next wave
	_spawn_enemy(level["waves"][current_wave]["enemies"][current_enemy_batch])
	spawn_new = false
	wave_timer.set_wait_time(level["waves"][current_wave]["enemies"][current_enemy_batch].enemy_timer)
	wave_timer.start()
	
	
func _spawn_enemy(d):
	# instances enemy into map and sets nav goal to base
	var new_enemy = enemy.instance()
	new_enemy.init(d.sprite ,d.speed, d.health, d.damage, d.reach, d.attack_rate)
	new_enemy.position = get_node(d.path).position
	new_enemy.final_dest = path_end
	new_enemy.nav = nav
	global.nav = nav
	add_child(new_enemy)


func _increment_enemy():
	current_enemy += 1
	if(current_enemy > level["waves"][current_wave]["enemies"][current_enemy_batch].quantity - 1):
		current_enemy = 0
		current_enemy_batch += 1
		if(current_enemy_batch > level["waves"][current_wave]["enemies"].size() - 1):
			current_enemy_batch = 0
			current_wave += 1
			if(current_wave > level["waves"].size() - 1):
				current_wave = 0
				waves_over = true
				wave_timer.stop()


func _on_Timer_timeout():
	_increment_enemy()
	if not waves_over:
		spawn_new = true
		
