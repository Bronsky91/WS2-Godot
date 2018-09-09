extends Area2D

export var speed = 450
export var damage = 10
var target = null

func _ready():
	connect("area_entered", self, "_on_area_entered")

func _process(delta):
	if target:
		position = (Vector2(position.x, position.y) + Vector2(target.position.x, target.position.y)) * speed * delta


func _on_area_entered(area):
	print(area.name)
	if area.name == "Enemy":
		area.add_damage(damage)
		queue_free()

