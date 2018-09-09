extends Area2D

const SPEED = 200

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func _process(delta):
	position.x += SPEED * delta
	
