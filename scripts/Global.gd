extends Node

var ult_charge = 0					# Current ultimate meter charge value
var ult_max = 1000					# Ultimate meter maximum charge value
var _ult_damage_to_charge = .1		# What damage dealt is multiplied by before being added to ultimate charge
var game							# Reference to Game node (self-registers onready)	
var current_level = 1
var restarted = false
var node_to_hide = null
var base_hp = 100					# Current base health value
var base_hp_max = 100				# Base maximum health value
var mana = 200
var mana_max = 200
var tome_library # JSON File
var cursor_tile_x = 0
var cursor_tile_y = 0
var cursor_tile_pos = Vector2()
var cursor_tile_path = false
const TILE_WIDTH = 64
const TILE_HEIGHT = 64


func _ready():
	var file = File.new()
	file.open("res://config/tomes/tome_library.json", file.READ)
	var text = file.get_as_text()
	tome_library = JSON.parse(text).result
	file.close()
	
	
func increase_ult_charge(num):
	# Increase the ultimate charge by raw damage multiplied by dampener value
	ult_charge += (num * _ult_damage_to_charge)
	
	# Cap ultimate charge at max value if it exceeds it
	if (ult_charge >= ult_max):
		ult_charge = ult_max
		# If at max value, change meter color
		game.get_ref().get_node("TowerDefenseHUD/UltimateMeter").set("modulate",Color(0.0,0.0,1.0))
	else:
		# If not at max value, ensure meter color is set to default
		game.get_ref().get_node("TowerDefenseHUD/UltimateMeter").set("modulate",Color(1.0,1.0,1.0))
	# Increase ultimate meter fill bar to match charge value
	game.get_ref().get_node("TowerDefenseHUD/UltimateMeter/Fill").set_value(ult_charge)


func decrease_ult_charge(num):
	# Decrease the ultimate charge by value specified
	ult_charge -= num
	# Ensure meter color is set to default
	game.get_ref().get_node("TowerDefenseHUD/UltimateMeter").set("modulate",Color(1.0,1.0,1.0))
	# Increase ultimate meter fill bar to match charge value
	game.get_ref().get_node("TowerDefenseHUD/UltimateMeter/Fill").set_value(ult_charge)


func get_tile_pos(x, y):
	return Vector2(
        (int(x) * 64) + (TILE_WIDTH / 2),
        (int(y) * 64) + (TILE_HEIGHT / 2)
    )

func mana_bar(num):
	if game.get_ref():
		game.get_ref().get_node("TowerDefenseHUD/ManaMeter/Fill").set_value(num)
	
	
func hp_bar(num):
	if game.get_ref():
		game.get_ref().get_node("TowerDefenseHUD/HealthMeter/Fill").set_value(num)
	

func on_node_entered():
	if(node_to_hide != null and node_to_hide.get_ref()):
		node_to_hide.get_ref().set_visibility(false)
		
		
func on_node_exited():
	if(node_to_hide != null and node_to_hide.get_ref()):
		node_to_hide.get_ref().set_visibility(true)


func hit_base(damage):
	if damage >= base_hp:
		hp_bar(0)
		print("Harry Potter is dead")
		get_tree().change_scene("res://scenes/GameOver.tscn")
	else:
		base_hp -= damage
		hp_bar(base_hp)
	
	