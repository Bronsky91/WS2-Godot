extends KinematicBody2D

export var speed = 450
export var damage = 10
var direction = Vector2(0, -1)
var target = null
var repos = Vector2()
var repos_velo = Vector2()


func _ready():
	connect("area_entered", self, "_on_area_entered")

func _process(delta):
	pass
		
func _physics_process(delta):
	if target:
		var pos = get_position()
		direction = (target.get_global_position() - get_global_position()).normalized()
		var rad_angle = atan2(direction.x, -direction.y)
		set_rotation(rad_angle)
		set_position(pos + (direction * speed * delta))

func _on_area_entered(area):
	print('colliding with' + area.name)
	if area.name == "Enemy":
		area.add_damage(damage)
		queue_free()

