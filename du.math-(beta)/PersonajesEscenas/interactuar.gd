extends Node2D

@onready var jugador = $"../Jugador"  # Ajusta esta ruta si el jugador está en otra ubicación

func _on_Area2D_body_entered(body: Node) -> void:
	if body == jugador:
		get_tree().change_scene_to_file("res://Escenas/Etapa1_BETA.tscn")
