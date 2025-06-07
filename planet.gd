# Planet.gd
# Attach this script to the planet node (a StaticBody2D).
# This script holds the gravity value and now also handles the planet's rotation.
extends StaticBody2D

# This controls the speed of the planet's rotation in radians per second.
# A positive value spins it counter-clockwise, a negative value clockwise.
@export var rotation_speed: float = 0.4

var gravity_node: Node2D
var gravity_offset: Vector2

var rng = RandomNumberGenerator.new()

const SPACESHIP_MASS = 10
const GRAVITY_CONSTANT: float = 350.0
const MASS_PER_RADIUS_PIXEL: float = 100.0

@export var radius: float
var mass: float

var surface_gravity: Vector2

func _ready():
	# Initialize random number generator
	rng.randomize()
	
	# Set the gravity node
	gravity_node = $GravityArea
	
		# Add different rotation speeds and direction
	rotation_speed = random_number(0.5, 3) * random_direction()
	rotation_speed = 3
	
	# Make the planets different sizes
	var scale_factor = random_number(0.5 , 3)
	scale_factor = 3
	scale *= scale_factor
	
	# Change the scale of the children too
	for child in self.get_children():
		child.scale *= scale_factor
	
	# Get the radius for ease of calculations with the spaceship
	var collision_surface = self.get_node("PlanetSurface") as CollisionShape2D
	
	radius = collision_surface.shape.radius * global_scale.x * scale_factor
	mass = radius * MASS_PER_RADIUS_PIXEL
	
	surface_gravity = get_gravity_force(Vector2.ONE)
	print("Radius, Mass, Grav: \n\t", radius, "\n\t", mass, "\n\t", surface_gravity)
	
	# Add this node to the "planets" group when the scene starts.
	# This allows the spaceship to easily find it without a direct node path.
	add_to_group("planets")


func _physics_process(delta):
	# Increment the node's rotation by the speed multiplied by delta.
	# Using delta makes the rotation smooth and independent of the frame rate.
	rotation += rotation_speed * delta
	
	# Keep the collision box from rotating
	gravity_node.rotation -= rotation_speed * delta
	
	for body in $GravityArea.get_overlapping_bodies():
		if not body is RigidBody2D:
			continue
		
		var vector_to_spaceship = (global_position - body.global_position)
		body.apply_central_gravity(get_gravity_force(vector_to_spaceship))


func get_gravity_force(vector_to_spaceship: Vector2) -> Vector2:
	var distance_to_spaceship = vector_to_spaceship.length()
	var direction_to_spaceship = vector_to_spaceship.normalized()
	
	var gravity_force = (GRAVITY_CONSTANT * SPACESHIP_MASS * mass) / (distance_to_spaceship ** 2)	
	return gravity_force * direction_to_spaceship


func random_number(low, high):
	return rng.randf_range(low, high)
	
	
func random_direction():
	var random_direction = rng.randi_range(-1, 0)
	if random_direction == 0:
		random_direction = 1
	
	return random_direction
