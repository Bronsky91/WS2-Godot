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
	# Increase the ultimate charge by raw damage multiplied by dampener value
	ult_charge += (num * _ult_damage_to_charge)
	
	# Cap ultimate charge at max value if it exceeds it
	if (ult_charge >= ult_max):
		ult_charge = ult_max
		# If at max value, change meter color
		game.get_node("TowerDefenseHUD/UltimateMeter").set("modulate",Color(0.0,0.0,1.0))
	else:
		# If not at max value, ensure meter color is set to default
		game.get_node("TowerDefenseHUD/UltimateMeter").set("modulate",Color(1.0,1.0,1.0))
	# Increase ultimate meter fill bar to match charge value
	game.get_node("TowerDefenseHUD/UltimateMeter/Fill").set_value(ult_charge)
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
