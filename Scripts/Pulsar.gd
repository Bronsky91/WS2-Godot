extends "res://Scripts/Rune.gd"

onready var beam = $Beam
onready var beam_area = $Beam/Area2D
onready var beam_sprite = $Beam/Area2D/Sprite
var pattern = []
var enemies
var step = 0
var beam_offset = 0


func _ready():
	pattern = [Vector2(0,90), Vector2(-90, 0), Vector2(0, -90), Vector2(90,0)]
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	resize_sprite(beam_sprite, _range)
	resize_shape(shape, beam_sprite)
	beam_offset = sprite_height_offset(beam_sprite)
	beam_area.position = Vector2( 0, beam_offset )
	collision.set_shape(shape)
	beam_area.add_child(collision)
	pulse_timer.set_wait_time(_speed)
	pulse_timer.start()


func _process(delta):
	if step <= 3 and not firing:
		firing = true
		var direction = (pattern[step] - Vector2(0,0)).normalized()
		var rad_angle = atan2(-direction.x, direction.y)
		beam.set_rotation(rad_angle)
		step += 1
		if step == 4:
			step = 0


func resize_sprite(sprite, height):
	sprite.scale = Vector2(sprite.scale.x, height / sprite.texture.get_height())


func resize_shape(shape, sprite):
	var size = sprite.texture.get_size() * sprite.get_scale()
	shape.set_extents(size/2)


func sprite_height_offset(sprite):
	return ( (sprite.texture.get_size() * sprite.get_scale()) / 2 ).y


func _on_PulseTimer_timeout():
	rearm()


func _on_Area2D_body_entered(body):
	enemies = get_tree().get_nodes_in_group("enemies")
	if body in enemies:
		body.take_damage(_damage)
		enemies = null