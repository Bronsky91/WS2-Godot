extends "res://Scripts/Rune.gd"

export(PackedScene) var minion

onready var rune_range = $Area2D/CollisionShape2D

var enemies

func _ready():
	rune_range.shape.radius = _range
	

func _process(delta):
	pass
			
			
func on_target_died(body):
	_summon(minion, _mob_stats, body.position)


func _on_Area2D_body_entered(body):
	enemies = get_tree().get_nodes_in_group("enemies")
	if body in enemies and not body.is_connected('died', self, 'on_target_died'):
		body.connect('died', self, 'on_target_died', [body])


func _on_Area2D_body_exited(body):
	enemies = get_tree().get_nodes_in_group("enemies")
	if body in enemies and body.is_connected('died', self, 'on_target_died'):
		body.disconnect('died', self, 'on_target_died')
