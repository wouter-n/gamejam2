extends Node2D

@onready var parallax_background: ParallaxBackground = $ParallaxBackground
@onready var anim_ship = $ParallaxBackground/Ship
@onready var anim_flames = $ParallaxBackground/Flames

const SCROLL_SPEED : float = 200.0 # px / second

func _process(delta : float):
	parallax_background.scroll_offset.x -= delta * SCROLL_SPEED
	anim_ship.play("Ship")
	anim_flames.play("Flames")
