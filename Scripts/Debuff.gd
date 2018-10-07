extends Node

var next_affliction_cycle
var affliction_counter = 0
var affliction_max = 0
var _debuff_details
var host # enemy that has the debuff attached

onready var debuff_timer = $DebuffTimer

func _ready():
	host = get_parent()
	next_affliction_cycle = true # starts first affliction cycle


func _process(delta):
	if host.afflictions.has(_debuff_details["class"]) and next_affliction_cycle:
	# Still need to update logic to be able stack debuffs
		debuff_stack(_debuff_details)
	
	
func init(debuff_details):
	_debuff_details = debuff_details
	
	
func debuff_stack(debuff):
	# Applies and stacks the debuff with the proper duration and occurance timer
	affliction_max = debuff["duration"]
	if debuff["reoccuring"] > 0:
		debuff_timer.set_wait_time(debuff["reoccuring"])
		debuff_timer.start()
	next_affliction_cycle = false
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
	# Set next debuff cycle for duration
	if affliction_counter <= affliction_max:
		affliction_counter += 1
		next_affliction_cycle = true
	else:
	# Ends debuff
		var affliction = host.afflictions.find(_debuff_details['class'])
		host.afflictions.remove(affliction)
		affliction_counter = 0
		host.remove_debuffs()
		debuff_timer.stop()
	
