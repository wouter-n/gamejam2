extends CharacterBody2D

const SPEED = 300.0

@onready var screen_size = get_viewport_rect().size

func _physics_process(_delta):
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
