extends Control

@export var main_game_scene: PackedScene = preload("res://level.tscn")

var countdown := 5

@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var settings: TabContainer = $CanvasLayer/Panel/Settings

func _ready() -> void:
	ui_layer.hide()
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

func _input(event: InputEvent):
	if event.is_action_pressed("Escape"):
		if not ui_layer.visible:
			show_ui_layer()
		else:
			resume_game()

func show_ui_layer():
	pause_game()
	ui_layer.show()
	reset_focus()

func reset_focus():
	$CanvasLayer/Panel/PauseMenu/Resume.grab_focus()

func pause_game():
	Engine.time_scale = 0

func resume_game():
	Engine.time_scale = 1
	settings.hide()
	ui_layer.hide()

func _on_resume_pressed():
	resume_game()

func _on_option_pressed():
	settings.show()
	settings.reset_focus()

func _on_main_menu_pressed():
	Utilities.switch_scene("MainMenu", self)
