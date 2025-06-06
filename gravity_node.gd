extends Area2D

@export var FORCE: float
@export var RADIUS: float

func _ready() -> void:
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.scale.x = RADIUS
	shape.scale.y = RADIUS
	add_child(shape)
	print("CollisionShape radius x: ", shape.scale.x)
	
func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if not body.has_method("apply_central_gravity"):
			continue
		
		var direction = (global_position - body.global_position).normalized()
		body.apply_central_gravity(direction * FORCE * delta)
