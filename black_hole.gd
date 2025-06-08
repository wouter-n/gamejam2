# File: moving_hazard.gd
extends Area2D

## The node representing the player. Assign this in the Godot editor.
@export var player_node: NodePath

## The group name for nodes that this hazard should delete on contact.
@export var deletable_group_name: StringName = &"planets"

## The starting speed of the area in pixels per second.
@export var initial_speed: float = 250.0

## How much the speed increases every second.
@export var acceleration: float = 10

@onready var animated_body: AnimatedSprite2D = $Body
@onready var animated_tentacles: AnimatedSprite2D = $Tentacles
@onready var animated_tentacles2: AnimatedSprite2D = $Tentacles2
@onready var animated_tentacles3: AnimatedSprite2D = $Tentacles3
@onready var animated_tentacles4: AnimatedSprite2D = $Tentacles4
@onready var animated_tentacles5: AnimatedSprite2D = $Tentacles5

var _current_speed: float
var _player: Node2D

func _ready() -> void:
	# Store the initial speed.
	_current_speed = initial_speed
	animated_body.play("default")
	animated_tentacles.play("default")
	animated_tentacles2.play("default")
	animated_tentacles3.play("default")
	animated_tentacles4.play("default")
	animated_tentacles5.play("default")

	
	
	# Get the player node from the assigned path.
	if not player_node.is_empty():
		_player = get_node_or_null(player_node) as Node2D

	# Connect signals for detecting both physics bodies and other areas.
	# This ensures it works whether your planets are StaticBody2D or Area2D.
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	# Exit the function if the player node wasn't found.
	if not _player:
		return

	# 1. Increase speed over time
	_current_speed += acceleration * delta
	
	# 2. Move to the right based on the current speed
	global_position.x += _current_speed * delta
	
	# 3. Keep the vertical position aligned with the player
	global_position.y = _player.global_position.y


## This function is called when a PhysicsBody2D/3D enters.
func _on_body_entered(body: Node2D) -> void:
	# First, check if the body is the player.
	if body == _player:
		if _player.has_method("death_animation"):
			_player.call("death_animation")
		else:
			_player.queue_free()
	# If not the player, check if it belongs to the deletable group.
	elif body.is_in_group(deletable_group_name):
		if body.has_method("planet_destroy"):
			body.call("planet_destroy")
		else:
			body.queue_free()


## This function is called when another Area2D enters.
func _on_area_entered(area: Area2D) -> void:
	# Check if the area that entered belongs to the deletable group.
	# We don't need to check for the player here, as players are typically bodies.
	if area.is_in_group(deletable_group_name):
		area.queue_free() # Delete the node.
