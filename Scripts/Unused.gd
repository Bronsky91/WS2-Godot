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

# https://www.reddit.com/r/godot/comments/3ktq39/drawing_empty_circles_and_curves/
# TODO: Figure this out. Does not seem to work right, as-is...
func draw_empty_circle (circle_center, circle_radius, color, resolution):
	var draw_counter = 1
	var line_origin = Vector2()
	var line_end = Vector2()
	line_origin = circle_radius + circle_center
	
	while draw_counter <= 360:
		line_end = circle_radius.rotated(deg2rad(draw_counter)) + circle_center
		draw_line(line_origin, line_end, color)
		draw_counter += 1 / resolution
		line_origin = line_end
		
	line_end = circle_radius.rotated(deg2rad(360)) + circle_center
	draw_line(line_origin, line_end, color)