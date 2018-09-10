extends Area2D

export var speed = 450
export var damage = 25
var direction = Vector2(0, -1)
var target = null
var rune = null


func _ready():
	connect("area_entered", self, "_on_area_entered")

func _process(delta):
	pass

func _physics_process(delta):
	if target.get_ref():
		var pos = get_position()
		direction = (target.get_ref().get_global_position() - pos).normalized()
		var rad_angle = atan2(-direction.x, direction.y)
		set_rotation(rad_angle)
		set_position(pos + (direction * speed * delta))
	else:
		# TODO: special animation or behavior for fireball whose target dies before reaching it?
		queue_free()

func _on_area_entered(collidee):
	print('colliding with ' + collidee.name)
	if collidee.is_in_group('enemies'):
		rune.get_ref().rearm()
		collidee.take_damage(damage)
		queue_free()