extends Node

var affliction_counter = 0
var affliction_max = 0
var _debuff_details
var host # enemy that has the debuff attached

onready var debuff_timer = $DebuffTimer

func _ready():
	host = get_parent()
	

func _process(delta):
	pass
	
	
func init(debuff_details):
	_debuff_details = debuff_details
	affliction_max = debuff_details["duration"]
	if debuff_details["reoccuring"] > 0:
		debuff_timer.set_wait_time(debuff_details["reoccuring"])
		debuff_timer.start()
	
	
func debuff_stack(debuff):
	# Applies and stacks the debuff with the proper duration and occurance timer
	_debuff_calculus(debuff["operand"], debuff["attribute"], debuff["value"])


func _debuff_calculus(op, attribute, value):
	# Calculates effect of debuff taken from JSON to enemy
	if op == "subtract":
		if attribute == "health":
			host.take_damage(value)
		elif attribute == "speed" and host._speed > value:
			host._speed -= value
		elif attribute == "damage" and host._damage > value:
			host._damage -= value
	elif op == "add":
		if attribute == "health":
			host._health += value
		elif attribute == "speed":
			host._speed += value
		elif attribute == "damage":
			host._damage += value
	elif op == "multiply":
		if attribute == "health":
			host._health *= value
		elif attribute == "speed":
			host._speed *= value
		elif attribute == "damage":
			host._damage *= value
	elif op == "divide":
		if attribute == "health":
			host._health /= value
		elif attribute == "speed" and host._speed > value:
			host._speed /= value
		elif attribute == "damage" and host._damage > value:
			host._damage /= value
			

func _on_DebuffTimer_timeout():
	affliction_counter += 1
	# Set next debuff cycle for duration
	if affliction_counter <= affliction_max:
		print(affliction_counter)
		debuff_stack(_debuff_details)
		print(host._speed)
	elif _debuff_details["on_timer"]:
	# Ends debuff
		var affliction = host.afflictions.find(_debuff_details['name'])
		host.afflictions.remove(affliction)
		affliction_counter = 0
		host.remove_debuffs(_debuff_details)
		debuff_timer.stop()
		queue_free()

