extends Node

@onready var in_game_music: AudioStreamPlayer = $in_game_music
@onready var in_menu_music: AudioStreamPlayer = $in_menu_music
@onready var sound_player: AudioStreamPlayer = $SoundPlayer


@onready var death_sound: AudioStreamPlayer = $Death
@onready var takeoff_sound: AudioStreamPlayer = $Takeoff
@onready var game_over: AudioStreamPlayer = $GameOver


func _ready():
	pass # Replace with function body.

func play_button_sound():
	sound_player.play()
	
func in_game_music_play():
	in_game_music.play()

func in_menu_music_play():
	in_menu_music.play()

func stop_music():
	if in_game_music and is_instance_valid(in_game_music):
		if in_game_music.playing:
			in_game_music.stop()

	if in_menu_music and is_instance_valid(in_game_music):
		if in_menu_music.playing:
			in_menu_music.stop()
			
			
func play_death_sound():
	death_sound.play()

func play_takeoff_sound():
	takeoff_sound.play()

func game_over_play():
	game_over.play()
