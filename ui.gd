# Attach this script to your UI node.
# It will ensure the node always faces the screen, ignoring the parent's rotation.

extends Node2D # Or Control, depending on your UI node's type

func _process(delta: float) -> void:
	# This forces the node's global rotation to be zero every frame.
	# 'global_rotation' is its rotation relative to the world, in radians.
	# By continually setting it to 0, you cancel out any rotation
	# inherited from the parent (the Spaceship).
	global_rotation = 0
