extends "res://Scripts/Rune.gd"

export(PackedScene) var minion


func _ready():
	pass

func _process(delta):
	if not firing and not global.end_level:
		_summon(minion, _mob_stats, position)
