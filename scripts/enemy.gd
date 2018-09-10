extends Area2D

const SPEED = 200
export var health = 125


func _ready():
	add_to_group("enemies")
	
	
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
