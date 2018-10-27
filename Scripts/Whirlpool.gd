extends "res://Scripts/Rune.gd"

onready var rune_range = $Area2D/CollisionShape2D

var debuff = {
	"name": "whirlpool",
	"attribute": "speed",
	"operand": "divide",
	"value": 2,
	"reoccuring": 0.1,
	"duration": 1,
	"on_timer": false
}


func _ready():
	rune_range.shape.radius = _range


func _process(delta):
	pass


func _on_Area2D_body_entered(body):
	apply_debuff(debuff, weakref(body))


func _on_Area2D_body_exited(body):
	body.remove_debuffs(debuff)

