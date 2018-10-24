extends "res://Scripts/Rune.gd"

export(PackedScene) var spell

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	time += delta #
	target = choose_target()
	if target != null and not firing:
		_shoot(target, spell)