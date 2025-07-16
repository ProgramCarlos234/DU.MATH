extends Area2D

@export var escena_destino: String = "res://Scenas/ScenasEntorno/Mapa_juego.tscn"

func _ready():
	add_to_group("portal")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("jugador"):
		cambiar_escena()

func cambiar_escena():
	if ResourceLoader.exists(escena_destino):
		# Opción 1: Usar GameManager
		GameManager._AbrirEscenaDirecta(escena_destino)
		# Opción 2: Cambiar directamente
		# get_tree().change_scene_to_file(escena_destino)
	else:
		printerr("Error: Escena no encontrada")
