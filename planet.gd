# Planet.gd
# Attach this script to the planet node (a StaticBody2D).
# This script holds the gravity value and now also handles the planet's rotation.
extends StaticBody2D

# This is our simplified "gravitational mass". Higher values mean stronger gravity.
@export var gravity_strength: float = 3000000.0
# This controls the speed of the planet's rotation in radians per second.
# A positive value spins it counter-clockwise, a negative value clockwise.
@export var rotation_speed: float = 0.4


var rng = RandomNumberGenerator.new()

var radius: float

func _ready():
	# Add this node to the "planets" group when the scene starts.
	# This allows the spaceship to easily find it without a direct node path.
	add_to_group("planets")
	
	rng.randomize()
	
	# Add different rotation speeds
	rotation_speed = random_number(0.5, 5)
	
	# Make the planets different sizes
	var scale_factor = random_number(0.5 , 3)
	scale *= scale_factor
	
	# Change the scale of the children too
	for child in self.get_children():
		child.scale *= scale_factor
	
	# Get the radius for ease of calculations with the spaceship
	var collision_surface = self.get_node("PlanetSurface") as CollisionShape2D
	radius = collision_surface.shape.radius * global_scale.x
	
	gravity_strength *= scale_factor
	

func _physics_process(delta):
	# Increment the node's rotation by the speed multiplied by delta.
	# Using delta makes the rotation smooth and independent of the frame rate.
	rotation += rotation_speed * delta


func random_number(low, high):
	return rng.randf_range(low, high)
	
