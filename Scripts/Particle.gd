extends Particles2D

func init(part: String):
	process_material = load("res://Resources/Particles/"+part+".tres")
	texture = load("res://Assets/"+part+"_part.png")

func _process(delta):
	print(emitting)
	if not emitting:
		queue_free()
