# Hereda de Area2D para detectar cuerpos que entran y salen
extends Area2D

# Variable exportada que determina qué escena debe abrirse cuando el jugador interactúa
@export var Indicador_mundo: int

func _on_body_entered(body: Node2D) -> void:
	# Verifica que el cuerpo que entró sea el jugador
	if body.name == "Jugador":
		# Le pasa el valor del indicador al jugador
		body.valor = Indicador_mundo
		
		# Activa la bandera en el GameManager que permite la interacción
		GameManager.DentroArea = true
	pass # Replace with function body.

func _on_body_exited(body: Node2D) -> void:
	# Verifica que sea el jugador quien salió
	if body.name == "Jugador":
		# Desactiva la bandera de interacción en el GameManager
		GameManager.DentroArea = false
