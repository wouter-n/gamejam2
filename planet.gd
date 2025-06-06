extends StaticBody2D

# Use @export to make this variable editable in the Inspector.
# This is our simplified "gravitational mass". Higher values mean stronger gravity.
# A good starting value might be between 100,000 and 500,000.
@export var gravity_strength: float = 15000000.0

func _ready():
	# Add this node to the "planets" group when the scene starts.
	# This allows the spaceship to easily find it without a direct node path.
	add_to_group("planets")
