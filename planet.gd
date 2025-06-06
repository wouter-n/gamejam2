extends Node2D

@export var TEXTURE: Texture2D
@export var RADIUS: float = 120.0
@export var STRENGTH: float = 200

var PIXELS: int = 1129

func _ready():
	$Sprite2D.texture = TEXTURE
	$Sprite2D.scale = Vector2.ONE * (RADIUS / (PIXELS / 2))
	
	$Gravity.RADIUS = RADIUS * 2.0
	$Gravity.FORCE = STRENGTH
	print("Grav Radius: ", $Gravity.RADIUS)
	print("Grav Force: ", $Gravity.FORCE)
