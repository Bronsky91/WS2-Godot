extends CanvasLayer


func _ready():
	pass


func _on_Story_pressed():
	get_tree().change_scene("res://Scenes/LevelSelection.tscn")


func _on_Exit_pressed():
	get_tree().quit()
