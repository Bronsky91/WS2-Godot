extends HSlider

onready var global = get_node("/root/Global")
onready var rune = $Rune
var disabled = false


func _ready():
	#value = get_parent().power_level
	pass
	
	
func _process(delta):
	pass


func set_visibility(visible):
	if(visible):
		show()
		disabled = false
	else:
		hide()
		disabled = true
