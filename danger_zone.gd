extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if "warning" in body:
		body.warning = true


func _on_body_exited(body: Node2D) -> void:
	if "warning" in body:
		body.warning = false
