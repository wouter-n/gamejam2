# Spaceship.gd
# Attach this script to the spaceship (a RigidBody2D).
# Includes gravity, player controls, auto-orbit, and trajectory prediction.
extends RigidBody2D

# --- Player Control Variables ---
@export var thrust_force: float = 100.0
@export var rotation_velocity: float = 2.0
@export var braking_dampening: float = 1.0
@export var launch_impulse: float = 1000

# --- Orbit Autopilot Variables ---
@export_group("Orbit Autopilot")
# How quickly the autopilot rotates the ship to the correct angle.
@export var orbit_correction_speed: float = 5.0
# How strongly the autopilot corrects velocity errors to maintain orbit.
# Higher values are more responsive but can be jerky.
@export var orbit_thrust_factor: float = 10.0

# --- Trajectory Prediction Variables ---
@export_group("Trajectory Prediction")
# If true, the trajectory line will be shown.
@export var show_trajectory: bool = true
# The number of points in the prediction line.
@export var prediction_steps: int = 1000
# The time between each predicted point, in seconds. A smaller value is more accurate.
@export var prediction_step_duration: float = 0.1

# --- Private Variables ---
var planets: Array = []
var landed_on_body: Node2D = null
var auto_orbit_enabled: bool = false
# A reference to the Line2D node for the trajectory.
@onready var trajectory_line: Line2D = $TrajectoryLine if has_node("TrajectoryLine") else null

func _ready():
	# --- Setup and Validation ---
	planets = get_tree().get_nodes_in_group("planets")
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

	if not contact_monitor:
		print_rich("[color=yellow]WARNING:[/color] Contact Monitor is disabled on the Spaceship node. Landing/launching will not work. Please enable it in the Inspector.")
	elif max_contacts_reported == 0:
		print_rich("[color=yellow]WARNING:[/color] Max Contacts Reported is 0 on the Spaceship node. Landing/launching may not work. Please set it to a value greater than 0 in the Inspector.")
	
	if trajectory_line == null:
		print_rich("[color=yellow]WARNING:[/color] No Line2D child node named 'TrajectoryLine' found. Trajectory prediction will be disabled.")


func _physics_process(delta):
	# Toggle auto-orbit mode on key press.
	if Input.is_action_just_pressed("ui_orbit"):
		auto_orbit_enabled = not auto_orbit_enabled
		if auto_orbit_enabled:
			landed_on_body = null 
	
	# Gravity should always be applied.
	apply_gravity_forces()
			
	# Choose which control scheme to use.
	if auto_orbit_enabled:
		maintain_orbit(delta)
	else:
		handle_player_input()

	# Update the trajectory line if enabled.
	if show_trajectory and is_instance_valid(trajectory_line):
		update_trajectory_prediction()

func maintain_orbit(delta):
	var target_planet = find_closest_planet()
	if not is_instance_valid(target_planet):
		auto_orbit_enabled = false
		return

	# --- Calculate Target Velocity for a Stable Circular Orbit ---
	var direction_to_planet = target_planet.global_position - global_position
	var distance = direction_to_planet.length()
	if distance < 1.0: return # Avoid division by zero if we are somehow inside the planet.

	# Determine the direction of the orbit (clockwise or counter-clockwise).
	# This preserves the ship's current momentum direction.
	var perpendicular_dir = direction_to_planet.orthogonal().normalized()
	if linear_velocity.length() > 1.0 and linear_velocity.dot(perpendicular_dir) < 0:
		perpendicular_dir = -perpendicular_dir
	
	# The ideal speed for a stable orbit is v = sqrt(GM/r).
	# GM is gravity_strength, r is distance.
	var target_speed = sqrt(target_planet.gravity_strength / distance)
	
	# This is the velocity vector we want to achieve.
	var target_velocity = perpendicular_dir * target_speed
	
	# --- Corrective Thrust ---
	# Calculate the difference between where we are going and where we want to go.
	var velocity_error = target_velocity - linear_velocity
	
	# Apply a proportional force to correct this error.
	var correction_force = velocity_error * orbit_thrust_factor
	apply_central_force(correction_force)
	
	# --- Angle Control ---
	# Smoothly point the ship in the direction of its target velocity.
	var target_angle = target_velocity.angle()
	rotation = lerp_angle(rotation, target_angle, orbit_correction_speed * delta)

func update_trajectory_prediction():
	trajectory_line.clear_points()

	var sim_position = global_position
	var sim_velocity = linear_velocity
	var body_mass = mass

	for i in range(prediction_steps):
		var total_gravity_force = Vector2.ZERO
		for planet in planets:
			if not is_instance_valid(planet):
				continue
			var dir_to_planet = planet.global_position - sim_position
			var dist_sq = dir_to_planet.length_squared()
			if dist_sq > 0:
				var gravity_mag = planet.gravity_strength / dist_sq
				total_gravity_force += dir_to_planet.normalized() * gravity_mag
		
		sim_velocity += (total_gravity_force / body_mass) * prediction_step_duration
		sim_position += sim_velocity * prediction_step_duration
		
		trajectory_line.add_point(to_local(sim_position))

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

func apply_gravity_forces():
	for planet in planets:
		if not is_instance_valid(planet):
			continue
		var direction_to_planet = planet.global_position - global_position
		var distance_sq = direction_to_planet.length_squared()
		if distance_sq == 0:
			continue
		var gravity_magnitude = planet.gravity_strength / distance_sq
		var gravity_vector = direction_to_planet.normalized() * gravity_magnitude
		apply_central_force(gravity_vector)

func handle_player_input():
	var rotation_dir = 0
	if Input.is_action_pressed("ui_left"):
		rotation_dir -= 1
	if Input.is_action_pressed("ui_right"):
		rotation_dir += 1
	angular_velocity = rotation_dir * rotation_velocity

	if Input.is_action_pressed("ui_up"):
		apply_central_force(transform.x * thrust_force)
		linear_damp = 0.0
	else:
		linear_damp = braking_dampening

	if Input.is_action_just_pressed("ui_accept") and is_instance_valid(landed_on_body):
		var launch_direction = (global_position - landed_on_body.global_position).normalized()
		if launch_direction == Vector2.ZERO:
			launch_direction = Vector2.UP
		apply_central_impulse(launch_direction * launch_impulse)

func _on_body_entered(body):
	if body.is_in_group("planets"):
		landed_on_body = body

func _on_body_exited(body):
	if body == landed_on_body:
		landed_on_body = null
