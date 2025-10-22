extends Area2D

@export var daño: int = 10

func _on_area_entered(body):
	if body.is_in_group("Jugador"):
		# Aquí puedes llamar al método de daño del jugador
		body.recibir_danio(daño)
