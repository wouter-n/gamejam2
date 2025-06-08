extends Control


func _ready() -> void:
	var score_label = $Labels/Loser
	score_label.text = "Score: %d" % Utilities.score
	AudioManager.game_over.play()

func _on_retry_pressed() -> void:
	Utilities.switch_scene("SampleGame", self)
	AudioManager.stop_music()
	AudioManager.in_game_music_play()

func _on_main_menu_pressed():
	Utilities.switch_scene("MainMenu", self)
