extends CharacterBody2D

@export var THRUST: float = 200.0
@export var MAX_THRUST: float = 400.0
@export var ROTATION: float = 2.0
@export var WEIGHT: float = 0.001

var HP = 3

# IMPORTANT: Replace "ThrustSprite" with the name of your AnimatedSprite2D node
@onready var thrust_sprite = $AnimatedSprite2D

func _ready():
	# Hides the sprite at the start of the game
	thrust_sprite.hide()

func apply_central_gravity(force: Vector2) -> void:
	velocity += force

func _physics_process(delta: float) -> void:
	if HP > 0:
		if Input.is_action_pressed("ui_left"):
			rotation -= ROTATION * delta
		elif Input.is_action_pressed("ui_right"):
			rotation += ROTATION * delta
			
		if Input.is_action_pressed("ui_select"):
			velocity += Vector2.UP.rotated(rotation) * THRUST * delta
			
			thrust_sprite.show()
			if not thrust_sprite.is_playing():
				# IMPORTANT: Replace "default" with your thruster animation's name
				thrust_sprite.play("default") 
		else:
			thrust_sprite.hide()
			thrust_sprite.stop()
			
		velocity = velocity.lerp(Vector2.ZERO, WEIGHT)
		if velocity.length() > MAX_THRUST:
			velocity = velocity.normalized() * MAX_THRUST
	
	move_and_slide()
