# Spaceship.gd
# Attach this script to the spaceship (a RigidBody2D).
# Includes gravity, player controls, auto-orbit, and trajectory prediction.
extends RigidBody2D

# --- Player Control Variables ---
@export var thrust_force: float = 500.0
@export var rotation_velocity: float = 6.0
@export var braking_dampening: float = 2.0
@export var launch_impulse: float = 500.0

# --- Private Variables ---
var planets: Array = []

enum LandingStates {CLEAN, NOSE, SIDE}
enum States {FLYING, LANDING, LANDED, TAKE_OFF}
var state: States = States.FLYING
var landing_states: LandingStates = LandingStates.CLEAN

var takeoff_distance = 100
var takeoff_direction: Vector2

var landed_planet: Node2D = null
var offset : Transform2D

var old_state = States.FLYING



func _ready():
	planets = get_tree().get_nodes_in_group("planets")
	
	connect("body_entered", Callable(self, "planet_touchdown"))


func _physics_process(delta: float) -> void:

	if state == States.TAKE_OFF and distance_to_closest_planet() > takeoff_distance:
		state = States.FLYING
	elif state == States.TAKE_OFF:
		taking_off(delta)
	#elif state in [States.FLYING, States.TAKE_OFF]:
	
	elif state == States.FLYING:
		handle_player_input()
	
	elif state == States.LANDED:	
		if Input.is_action_just_pressed("ui_accept"):
			#handle_take_off()
			taking_off(delta)
		else:
			# Move with the planet
			global_transform = landed_planet.global_transform * offset

	# For debugging
	if state != old_state:
		print("New state:", States.keys()[state])
		old_state = state


func planet_touchdown(body):

	if body.is_in_group("planets") and state != States.TAKE_OFF:
		var planet = body
		state = States.LANDED
		landed_planet = planet
		
		# CHECK ORIENTATION
		var direction = (global_position - planet.global_position).normalized()
		var dist_to_planet = (planet.global_position - global_position).normalized()
		var ship_down = -transform.x.normalized()
	
		var dot = ship_down.dot(dist_to_planet)
		if dot > 0.75:
			print("Proper landing")
		else:
			_explode()
				
		# Compute angle facing away from center (so ship is "standing up")
		var angle = direction.angle()
		rotation = angle
		offset = planet.global_transform.affine_inverse() * global_transform


func _explode() -> void:
	print("💥 KABOOM!")
	set_physics_process(false)
	set_process(false)
	# Optional: hide the ship or show a placeholder
	hide()
	# Optional: stop the entire scene
	get_tree().paused = true


func distance_from_landed_planet():
	if landed_planet == null:
		return INF
	var vector_to_planet = landed_planet.global_position - global_position
	return vector_to_planet.length()


func distance_to_closest_planet():
	var planet = find_closest_planet()
	
	if planet == null:
		return INF
	
	var distance_to_center = (planet.global_position - global_position).length()
	return distance_to_center - planet.radius


func find_closest_planet():
	var closest_planet = null
	var min_dist_sq = INF
	for planet in planets:
		if not is_instance_valid(planet):
			continue
		var dist_sq = global_position.distance_squared_to(planet.global_position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest_planet = planet
	
	return closest_planet


func short_angle_distance(a, b):
	return fmod((b - a + PI), TAU) - PI


func taking_off(delta):
	if Input.is_action_just_pressed("ui_accept") and landed_planet != null:
		state = States.TAKE_OFF
	
	var takeoff_direction = transform.x.normalized()
	var launch_power = 500 + landed_planet.radius * 6.0
	
	# Stop the ship from rotating
	angular_velocity = 0
	
	# Apply force
	apply_central_impulse(takeoff_direction * launch_power * delta)


func apply_central_gravity(force: Vector2) -> void:
	apply_central_force(force)


func handle_player_input():
	var rotation_direction = 0
	if Input.is_action_pressed("ui_left"):
		rotation_direction -= 1
	if Input.is_action_pressed("ui_right"):
		rotation_direction += 1
	
	angular_velocity = rotation_direction * rotation_velocity

	if Input.is_action_pressed("ui_up"):
		apply_central_force(transform.x.normalized() * thrust_force)
		
