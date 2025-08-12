extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador": # Verifica que sea el jugador quien salió
		GameManager._recibirDaño(1)# Desactiva la bandera de interacción en el GameManager
	pass # Replace with function body.
