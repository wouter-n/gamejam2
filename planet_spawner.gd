extends Node2D

@export var object_scene: PackedScene
@export var player: Node2D
@export var spawn_margin: float = 300.0 
@export var min_spacing: float = 1000.0  # minimum horizontal space between planets
@export var min_y_spacing: float = 600.0  # Minimum vertical spacing between planets
@export var vertical_padding: float = 400.0  # how far above/below screen edge planets can spawn


@onready var camera := get_viewport().get_camera_2d()

var last_spawn_x: float = -INF
var last_spawn_y: float = -INF

func spawn_planets():
	var cam_rect = camera.get_viewport_rect()
	var cam_size = cam_rect.size
	var cam_center = camera.global_position

	var start_x = cam_center.x + cam_size.x + spawn_margin * 2
	var screen_height = cam_size.y
	var min_y = cam_center.y - screen_height / 2 - vertical_padding
	var max_y = cam_center.y + screen_height / 2 + vertical_padding

	var num_to_spawn = randi_range(1, 2)

	var x = start_x
	var previous_y_positions: Array = []

	for i in range(num_to_spawn):
		var attempt = 0
		var spawn_y = 0.0

		while attempt < 10:
			spawn_y = randf_range(min_y, max_y)

			var too_close = false
			for y in previous_y_positions:
				if abs(y - spawn_y) < min_y_spacing:
					too_close = true
					break

			if not too_close:
				break

			attempt += 1

		previous_y_positions.append(spawn_y)

		var spawn_pos = Vector2(x, spawn_y)

		var new_planet = object_scene.instantiate()
		new_planet.global_position = spawn_pos
		get_parent().add_child(new_planet)

		# Advance x for next planet to ensure horizontal spacing
		x += min_spacing * randf_range(0.9, 1.2)

func _process(delta):
	if player == null or camera == null:
		return

	var player_x = player.global_position.x

	# Spawn only when player has moved far enough from last spawn
	if player_x > last_spawn_x + min_spacing:
		spawn_planets()
		last_spawn_x = player_x
