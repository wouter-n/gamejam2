# Planet.gd
# Attach this script to the planet node (a StaticBody2D).
# This script holds the gravity value and now also handles the planet's rotation.
extends StaticBody2D

# This is our simplified "gravitational mass". Higher values mean stronger gravity.
@export var gravity_strength: float = 100.0
# This controls the speed of the planet's rotation in radians per second.
# A positive value spins it counter-clockwise, a negative value clockwise.
@export var rotation_speed: float = 0.4
# This is how far beyond the planet scale the gravity extends
@export var gravity_range_multiplier: float = 3.0

var rng = RandomNumberGenerator.new()

var radius: float

func _ready():
	# Add this node to the "planets" group when the scene starts.
	# This allows the spaceship to easily find it without a direct node path.
	add_to_group("planets")
	
	rng.randomize()
	
	# Add different rotation speeds
	rotation_speed = random_number(0.5, 2)
	gravity_strength = random_number(100, 200)
	gravity_range_multiplier = random_number(7.0, 8.0)
	
	# Make the planets different sizes
	var scale_factor = random_number(0.5 , 3)
	scale *= scale_factor
	
	# Change the scale of the children too
	for child in self.get_children():
		#if child.name != "GravityArea":
			child.scale *= scale_factor
	
	# Get the radius for ease of calculations with the spaceship
	var collision_surface = self.get_node("PlanetSurface") as CollisionShape2D
	radius = collision_surface.shape.radius * global_scale.x
	
	gravity_strength *= scale_factor
	var gravity_area = $GravityArea
	var gravity_shape = gravity_area.get_node("CollisionShape2D").shape as CircleShape2D
	gravity_shape.radius = radius * gravity_range_multiplier
	

func _physics_process(delta):
	# Increment the node's rotation by the speed multiplied by delta.
	# Using delta makes the rotation smooth and independent of the frame rate.
	rotation += rotation_speed * delta
	for body in $GravityArea.get_overlapping_bodies():
		if not body is RigidBody2D:
			continue
		var direction = (global_position - body.global_position).normalized()
		body.apply_central_gravity(direction * gravity_strength)


func random_number(low, high):
	return rng.randf_range(low, high)
	
func _draw():
	var gravity_area_radius = radius * gravity_range_multiplier
	draw_circle(Vector2.ZERO, gravity_area_radius, Color(0.2, 0.6, 1.0, 0.3))  # Light blue, semi-transparent

func _process(delta):
	queue_redraw()  # Make sure the draw updates every frame in the editor too
