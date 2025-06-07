extends Node2D


var planet_scene: PackedScene = preload("res://planet.tscn")

# Generation spacing variables
var column_spacing := 500
var spawn_column_width := 1000
var vertical_spacing_min := 500
var vertical_spacing_max := 800

var max_spawn_distance := 640
var max_column_height := 3200

var player: Node2D
var last_spawn_x: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $Spaceship
	last_spawn_x = player.global_position.x + 250


func _process(delta: float) -> void:
	var player_x = player.global_position.x
	
	if last_spawn_x < player_x + max_spawn_distance:
		spawn_column(last_spawn_x + spawn_column_width)
		last_spawn_x += spawn_column_width + column_spacing
	
	
func spawn_column(column_start_x: float):
	var bottom_of_last_planet = player.global_position.y - max_column_height / 2
	var max_spawn_y = player.global_position.y + max_column_height / 2
		
	while bottom_of_last_planet < max_spawn_y:
		var planet = planet_scene.instantiate()
		
		planet.set_as_top_level(true)
		planet.setup_random_features()
		
		var planet_radius = planet.radius
		
		var x_offset = randf_range(planet_radius, spawn_column_width - planet_radius)
		var y_offset = randf_range(0, vertical_spacing_max - vertical_spacing_min)
		
		var x_pos = column_start_x + x_offset
		var y_pos = bottom_of_last_planet + planet_radius + y_offset + vertical_spacing_min
		
		var pos = Vector2(x_pos, y_pos)
		planet.global_position = pos
		add_child(planet)
	
		planet.set_as_top_level(false)
		bottom_of_last_planet = y_pos + planet_radius
