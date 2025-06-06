# Spaceship.gd
# Attach this script to the spaceship (a RigidBody2D).
# This script will find all planets and apply their gravitational forces to itself.
extends RigidBody2D

# --- Player Control Variables ---
@export var thrust_force: float = 100.0
@export var rotation_velocity: float = 4.0
# This is the amount of friction/drag applied when not thrusting.
# Higher values will make the ship stop faster. A good value is between 0.5 and 2.0.
@export var braking_dampening: float = 1.0
# The strength of the launch impulse when pressing spacebar on a planet's surface.
# This needs to be a large value to overcome mass and gravity.
@export var launch_impulse: float = 1000.0


# --- Private Variables ---
var planets: Array = []
# This will hold a reference to the planet we are currently landed on.
var landed_on_body: Node2D = null

func _ready():
	# Find all nodes in the "planets" group and store them in our array.
	planets = get_tree().get_nodes_in_group("planets")

	# Connect the body_entered and body_exited signals to our functions.
	# This is the key to reliable collision detection for this purpose.
	# NOTE: For these signals to work, you MUST enable "Contact Monitor"
	# in the Inspector for this RigidBody2D and set "Max Contacts Reported" to > 0.
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))


func _physics_process(delta):
	# Apply gravity from all planets in the scene.
	apply_gravity_forces()
	
	# Handle player input for movement.
	handle_player_input()

func apply_gravity_forces():
	# Iterate through each planet we found.
	for planet in planets:
		# A safety check in case a planet was removed from the scene during gameplay.
		if not is_instance_valid(planet):
			continue

		# --- Gravity Calculation (for each planet) ---
		var direction_to_planet = planet.global_position - self.global_position
		var distance_sq = direction_to_planet.length_squared()
		if distance_sq == 0:
			continue
		var gravity_magnitude = planet.gravity_strength / distance_sq
		var gravity_vector = direction_to_planet.normalized() * gravity_magnitude
		apply_central_force(gravity_vector)


func handle_player_input():
	# --- Rotation ---
	var rotation_dir = 0
	if Input.is_action_pressed("ui_left"):
		rotation_dir -= 0.2
	if Input. is_action_pressed("ui_right"):
		rotation_dir += 0.2
	angular_velocity = rotation_dir * rotation_velocity

	# --- Thrust & Dampening ---
	if Input.is_action_pressed("ui_up"):
		apply_central_force(transform.x * thrust_force)
		linear_damp = 0.0
	else:
		linear_damp = braking_dampening

	# --- Launch from planet surface ---
	# We now check our state variable instead of polling for collisions.
	if Input.is_action_just_pressed("ui_accept") and is_instance_valid(landed_on_body):
		# Calculate the direction away from the planet we're landed on.
		var launch_direction = (global_position - landed_on_body.global_position).normalized()
		
		# Failsafe in case the ship is exactly at the planet's center.
		if launch_direction == Vector2.ZERO:
			launch_direction = Vector2.UP # Default to launching straight up.

		# Apply an impulse for a powerful, instantaneous push.
		apply_central_impulse(launch_direction * launch_impulse)


# --- Signal Callbacks ---

func _on_body_entered(body):
	# This function is called automatically by the physics engine when a collision starts.
	if body.is_in_group("planets"):
		# If we've touched a planet, store a reference to it.
		landed_on_body = body

func _on_body_exited(body):
	# This function is called automatically when the collision ends.
	if body == landed_on_body:
		# If we've left the planet we were landed on, clear the reference.
		landed_on_body = null
