extends "res://Scripts/Rune.gd"

export(PackedScene) var minion

func _ready():
	pass

func _process(delta):
	time += delta #
	target = choose_target()
	if target != null and not target.get_ref().is_connected('died', self, 'on_target_died'):
		target.get_ref().connect('died', self, 'on_target_died')
			
			
func on_target_died():
	_summon(minion, _mob_stats, target.get_ref().position)