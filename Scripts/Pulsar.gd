extends "res://Scripts/Rune.gd"

onready var rune_range = $Area2D/CollisionShape2D
onready var beam = $Sprite2

var next_pattern = Vector2(0,0)
var pattern = []
var scales = []
var enemies
var step = 0


func _ready():
	pattern = [Vector2(0,-_range), Vector2(_range, 0), Vector2(0, _range), Vector2(-_range,0)]
	scales = [Vector2(5,1), Vector2(1,5), Vector2(5,1), Vector2(1,5)]
	

func _process(delta):
	if step <= 3 and not firing:
		pulse_timer.set_wait_time(_speed)
		pulse_timer.start()
		firing = true
		#rune_range.set_scale(scales[step])
		#rune_range.shape.b = Vector2(pattern[step])
		var direction = (pattern[step] - rune_range.offset()).normalized()
		var rad_angle = atan2(-direction.x, direction.y)
		rune_range.shape.set_rotation(rad_angle)
		rune_range.set_position(rune_range.shape.a + (direction * _speed * delta))
		print(rune_range.shape.extents)
		beam.set_rotation(rad_angle)
		beam.set_position(rune_range.shape.a + (direction * _speed * delta))
		step += 1
		if step == 4:
			step = 0
	

func _on_PulseTimer_timeout():
	rearm()


func _on_Area2D_body_entered(body):
	enemies = get_tree().get_nodes_in_group("enemies")
	if body in enemies:
		body.take_damage(_damage)
		print('entered damage')
