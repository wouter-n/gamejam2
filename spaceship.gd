# Spaceship.gd
# Attach this script to the spaceship (a RigidBody2D).
# Includes gravity, player controls, auto-orbit, and trajectory prediction.
extends RigidBody2D

# --- Player Control Variables ---
@export var thrust_force: float = 500.0
@export var rotation_velocity: float = 6.0
@export var braking_dampening: float = 2.0
@export var launch_impulse: float = 300

# --- Private Variables ---
var planets: Array = []
var HP: int = 3

enum LandingStates {CLEAN, NOSE, SIDE}
enum States {FLYING, LANDING, LANDED, TAKE_OFF}
var state: States = States.FLYING
var landing_states: LandingStates = LandingStates.CLEAN

var landing_distance = 250
#var landing_rotation_speed = 5.0

var landed_planet: Node2D = null
var offset : Transform2D

var old_state = States.FLYING

func _explode() -> void:
	print("💥 KABOOM!")
	set_physics_process(false)
	set_process(false)
	# Optional: hide the ship or show a placeholder
	hide()
	# Optional: stop the entire scene
	get_tree().paused = true

func _ready():
	planets = get_tree().get_nodes_in_group("planets")
	
	connect("body_entered", Callable(self, "planet_touchdown"))


func planet_touchdown(body):
	# Vector from planet center to ship

	if body.is_in_group("planets"):
		var planet = body
		state = States.LANDED
		landed_planet = planet
		# CHECK ORIENTATION
		var direction = (global_position - planet.global_position).normalized()
		var dist_to_planet = (planet.global_position - global_position).normalized()
		var ship_down = -transform.x.normalized()
	
		var dot = ship_down.dot(dist_to_planet)
		if dot > 0.75:
			print("Proper  landing")
		else:
			_explode()
				
		# Compute angle facing away from center (so ship is "standing up")
		var angle = direction.angle()
		rotation = angle
		offset = planet.global_transform.affine_inverse() * global_transform


func _physics_process(delta: float) -> void:

	if state == States.TAKE_OFF and distance_to_closest_planet() > landing_distance:
		state = States.FLYING
	elif state in [States.FLYING, States.TAKE_OFF]:
		handle_player_input()
	elif state == States.LANDED:
		# Move with the planet
		global_transform = landed_planet.global_transform * offset
		handle_take_off()

	# For debugging
	if state != old_state:
		print("New state:", States.keys()[state])
		old_state = state

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

func handle_take_off():
	if Input.is_action_just_pressed("ui_accept") and landed_planet != null:
		state = States.TAKE_OFF
		var launch_direction = (global_position - landed_planet.global_position).normalized()
		if launch_direction == Vector2.ZERO:
			launch_direction = Vector2.UP
		
		apply_central_impulse(launch_direction * launch_impulse)


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
		apply_central_force(transform.x * thrust_force)

#func reposition_for_landing(delta):
	#var landing_planet = find_closest_planet()
	#var direction = (global_position - landing_planet.global_position).normalized()
	#var landing_angle = direction.angle()
	#
	#var speed_factor = clamp(linear_velocity.length() / 250, 0.1, 5.0)
	#var effective_rotation_speed = landing_rotation_speed * speed_factor
	#
	#if abs(short_angle_distance(rotation, landing_angle)) < 0.01:
		#rotation = landing_angle
	#else:
		#rotation = lerp_angle(rotation, landing_angle, delta * effective_rotation_speed)
		
#func apply_gravity_forces():
	## HERE IS TO CHANGE GRAVITY LOGIC
	#for planet in planets:
		#if not is_instance_valid(planet):
			#continue
		#
		#var direction_to_planet = planet.global_position - global_position
		#var distance_sq = direction_to_planet.length_squared()
		#
		#if distance_sq == 0:
			#continue
		#
		#var gravity_magnitude = planet.gravity_strength / distance_sq
		#var gravity_vector = direction_to_planet.normalized() * gravity_magnitude
		#
		#apply_central_force(gravity_vector)
