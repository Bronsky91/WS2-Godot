var ahead = Vector2()
var ahead2 = Vector2()
const MAX_AVOID_FORCE = 50
const MAX_SEE_AHEAD = 50
var velocity = Vector2()


func avoid_collision():
	var most_threatening = find_obstacle()
	var avoidance = Vector2()
	if most_threatening != null:
		avoidance.x = ahead.x - most_threatening.position.x
		avoidance.y = ahead.y - most_threatening.position.y
		avoidance = avoidance.normalized()
		avoidance = avoidance * MAX_AVOID_FORCE
	else:
		avoidance = avoidance * 0
	return avoidance


func find_obstacle():
	var most_threatening = null
	var other_bodies = get_tree().get_nodes_in_group("enemies") + get_tree().get_nodes_in_group("minions")
	other_bodies.remove(other_bodies.find(self))
	for mob in other_bodies:
		var shape = mob.collider
		var collision = intersecting(ahead, ahead2, shape)
		if collision and (most_threatening == null or position.distance_to(shape.position) < position.distance_to(most_threatening.position)):
			most_threatening = shape
	return most_threatening


func intersecting(ahead, ahead2, shape):
	return shape.position.distance_to(ahead) <= shape.shape.radius || shape.position.distance_to(ahead2) <= shape.shape.radius;



#velocity = (path[0] - position).normalized() * _speed
#ahead = Vector2(0,0) + velocity.normalized() * MAX_SEE_AHEAD
#ahead2 = Vector2(0,0) + velocity.normalized() * MAX_SEE_AHEAD * 0.5
#print("pos: " + str(position) + ", vec2: " + str(Vector2(0,0)) + ", velocity: " + str(velocity) + ", ahead: " + str(ahead) + ", ahead2: " + str(ahead2) + ", avoid: " + str(avoid_collision()))
#velocity += avoid_collision()