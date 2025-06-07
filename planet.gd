# Planet.gd
# Attach this script to the planet node (a StaticBody2D).
# This script handles gravity, rotation, and texture randomization.
extends StaticBody2D

# --- EXPORTED VARIABLES ---
# This controls the speed of the planet's rotation in radians per second.
@export var rotation_speed: float = 0.4
# Drag your texture files from the FileSystem dock into these slots in the Inspector.
@export var textures: Array[Texture]
# Allow to be used from the spaceship
@export var radius: float


# --- CONSTANTS ---
const SPACESHIP_MASS = 10
const GRAVITY_CONSTANT: float = 300.0
const MASS_PER_RADIUS_PIXEL: float = 100.0

# --- CLASS VARIABLES ---
var rng = RandomNumberGenerator.new()
var mass: float


func _ready():
	# Initialize random number generator
	rng.randomize()

	# Add this node to the "planets" group when the scene starts.
	# This allows the spaceship to easily find it without a direct node path.
	add_to_group("planets")

func setup_random_features():
	randomize()
	# --- NEW: Randomly select a texture for the planet sprite ---
	var sprite = self.get_node("PlanetSprite") as Sprite2D
	if not textures.is_empty():
		if sprite:
			sprite.texture = textures.pick_random()
		else:
			print("Error: PlanetSprite node not found! Cannot set texture.")
	else:
		print("Warning: No textures assigned in the 'textures' array.")
	
	# Add different rotation speeds and direction
	rotation_speed = random_number(0.8, 3) * random_direction()
	
	# Make the planets different sizes
	var scale_factor = random_number(0.8, 1.2)
	scale *= scale_factor
	
	for child in get_children():
		child.scale *= scale_factor
	
	var collision_surface = self.get_node("PlanetSurface") as CollisionShape2D
	if collision_surface and collision_surface.shape is CircleShape2D:
		radius = collision_surface.shape.radius * global_scale.x * scale_factor
		mass = radius * MASS_PER_RADIUS_PIXEL
		#print("Radius, Mass: \n\t", radius, "\n\t", mass, "\n\t")
	else:
		print("Error: Could not find CollisionShape2D with a CircleShape2D to determine radius.")


func _physics_process(delta):
	# Increment the node's rotation by the speed multiplied by delta.
	# Using delta makes the rotation smooth and independent of the frame rate.
	rotation += rotation_speed * delta
	
	var gravity_node = self.get_node("GravityArea") as Area2D
	if gravity_node:
		gravity_node.rotation -= rotation_speed * delta
	
	# Apply gravity to bodies within the GravityArea
	for body in gravity_node.get_overlapping_bodies():
		if body is RigidBody2D:
			var vector_to_spaceship = (global_position - body.global_position)
			body.apply_central_force(get_gravity_force(vector_to_spaceship))


func get_gravity_force(vector_to_spaceship: Vector2) -> Vector2:
	var distance_sq = vector_to_spaceship.length_squared()
	if distance_sq <= 2500:
		return Vector2.ZERO

	var direction_to_spaceship = vector_to_spaceship.normalized()
	
	var gravity_force_magnitude = (GRAVITY_CONSTANT * SPACESHIP_MASS * mass) / distance_sq
	return direction_to_spaceship * gravity_force_magnitude


func random_number(low, high):
	return rng.randf_range(low, high)
	
	
func random_direction():
	if rng.randi_range(0, 1) == 0:
		return -1
	else:
		return 1
