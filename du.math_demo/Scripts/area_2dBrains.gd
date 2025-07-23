extends Area2D


func _on_body_entered(body: Node2D) -> void:
	print("Contacto")
	if body.name == "Jugador": 
		queue_free()
	pass
