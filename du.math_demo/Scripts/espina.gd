extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador":
		GameManager._recibirDaño(10)
	pass 
