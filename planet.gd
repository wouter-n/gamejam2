@tool
extends AnimatableBody2D

@export var planet_radius: float = 64:
	set(value):
		planet_radius = value
		update_visuals()
@export var planet_texture: Texture2D:
	set(value):
		planet_texture = value
		if is_inside_tree() and $Sprite2D:
			$Sprite2D.texture = planet_texture
		update_visuals()
@export var texture_pixels: int = 1129

func _ready() -> void:
	if Engine.is_editor_hint():
		update_visuals()
		
func _enter_tree() -> void:
	queue_redraw()
	
func update_visuals() -> void:
	if not is_inside_tree():
		return
	if $Sprite2D and planet_texture:
		$Sprite2D.texture = planet_texture
		var base_radius := texture_pixels / 2.0
		var scale_factor := planet_radius / base_radius
		$Sprite2D.scale = Vector2.ONE * scale_factor

	var shape = $CollisionShape2D.shape
	if shape is CircleShape2D:
		shape.radius = planet_radius
