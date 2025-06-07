extends Control

# In the Inspector, you can now easily set which scene to load next.
# IMPORTANT: Make sure this path points to your main game scene file.
@export var main_game_scene: PackedScene = preload("res://level.tscn")

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_packed(main_game_scene)
