@tool
extends Control

const SPLASH_DURATION := 2.0
const FADE_TIME := 1.0

@onready var boot_splash_color_rect: ColorRect = %BootSplashColorRect
@onready var boot_splash_texture_rect: TextureRect = %BootSplashTextureRect

func _ready() -> void:
	boot_splash_color_rect.modulate.a = 0.0
	boot_splash_texture_rect.modulate.a = 0.0

	if Engine.is_editor_hint():
		return

	# Fade-in
	var tween = create_tween()
	tween.tween_property(boot_splash_color_rect, "modulate:a", 1.0, FADE_TIME)
	tween.parallel().tween_property(boot_splash_texture_rect, "modulate:a", 1.0, FADE_TIME)
	await tween.finished

	await get_tree().create_timer(SPLASH_DURATION).timeout

	# Fade-out
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(boot_splash_color_rect, "modulate:a", 0.0, FADE_TIME)
	fade_out_tween.parallel().tween_property(boot_splash_texture_rect, "modulate:a", 0.0, FADE_TIME)
	await fade_out_tween.finished

	_change_to_main_menu()

func _change_to_main_menu() -> void:
	var main_menu_scene = load("res://scenes/main_menu.tscn")
	if main_menu_scene:
		get_tree().change_scene_to_packed(main_menu_scene)
	else:
		push_error("Impossible de charger la scène 'main_menu.tscn'. Vérifie le chemin.")
