extends "res://Scripts/Rune.gd"

onready var rune_range = $Area2D/CollisionShape2D


func _ready():
	rune_range.shape.radius = _range


func _process(delta):
	pass


func _on_Area2D_body_entered(body):
	body._speed = body._speed/2


func _on_Area2D_body_exited(body):
	body._speed = body._speed*2

