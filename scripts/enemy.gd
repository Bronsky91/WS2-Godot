extends Area2D

const SPEED = 200
export var health = 50

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func _process(delta):
	position.x += SPEED * delta

func _die():
	print("DEAD")
	# explosion / death animation
	queue_free()

func take_damage(damage):
	print("TAKING DAMAGE")
	health -= damage
	if health <= 0:
		_die()
