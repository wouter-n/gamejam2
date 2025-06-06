# Planet.gd
# Attach this script to the planet node (a StaticBody2D).
# This script holds the gravity value and now also handles the planet's rotation.
extends StaticBody2D

# This is our simplified "gravitational mass". Higher values mean stronger gravity.
@export var gravity_strength: float = 3000000.0
# This controls the speed of the planet's rotation in radians per second.
# A positive value spins it counter-clockwise, a negative value clockwise.
@export var rotation_speed: float = 0.2


func _ready():
	# Add this node to the "planets" group when the scene starts.
	# This allows the spaceship to easily find it without a direct node path.
	add_to_group("planets")

func _physics_process(delta):
	# Increment the node's rotation by the speed multiplied by delta.
	# Using delta makes the rotation smooth and independent of the frame rate.
	rotation += rotation_speed * delta
   
