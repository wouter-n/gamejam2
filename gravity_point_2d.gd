@tool
extends Area2D

@export var gravity_force: float = 200.0
@export var radius: float = 20.0:
	set(value):
		radius = value
		update_visuals()

func _ready() -> void:
	if Engine.is_editor_hint():
		update_visuals()
	else:
		var circle = $CollisionShape2D.shape as CircleShape2D
		if circle:
			circle.radius = radius
		else:
			push_error("GravityPoint2D needs to be set to CircleShape")

func update_visuals() -> void:
	if $CollisionShape2D and $CollisionShape2D.shape is CircleShape2D:
		$CollisionShape2D.shape.radius = radius
	queue_redraw()
	
func _enter_tree() -> void:
	queue_redraw()

func _draw() -> void:
	#if not Engine.is_editor_hint():
		#return
	draw_circle(Vector2.ZERO, radius, Color(0.2, 0.8, 1.0, 0.2))
	draw_circle(Vector2.ZERO, radius, Color.RED, 0)
	

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if not body.has_method("apply_central_gravity"):
			continue
			
		var direction = (global_position - body.global_position).normalized()
		body.apply_central_gravity(direction * gravity_force * delta)
