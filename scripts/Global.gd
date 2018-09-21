extends Node

var ult_charge = 0
var ult_max = 100
var _ult_damage_to_charge = .1
var game

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func mod_ult_charge(num):
	ult_charge += (num * _ult_damage_to_charge)
	if (ult_charge > ult_max):
		ult_charge = ult_max
	#game.print_tree()
	game.get_node("TowerDefenseHUD/UltimateMeter/Fill").set_value(ult_charge)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
