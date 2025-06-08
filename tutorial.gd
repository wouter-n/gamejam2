extends Control

@export var main_game_scene: PackedScene = preload("res://level.tscn")

var countdown := 5

func _ready() -> void:
	start_countdown()

func start_countdown() -> void:
	countdown_loop()

func countdown_loop() -> void:
	var label = $Countdown
	for i in range(countdown, 0, -1):
		if label:
			label.text = str(i)
		else:
			print("ERREUR : Label introuvable !")
		await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_packed(main_game_scene)
