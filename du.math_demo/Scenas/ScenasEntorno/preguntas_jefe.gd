extends Node2D

signal pregunta_terminada(correcta)

var respuesta_correcta = "A" # Puedes cambiarla según la pregunta
var respuesta_elegida = null

func _ready():
	# Asegurar que el jugador pueda moverse mientras responde
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("Interactuar") and respuesta_elegida != null:
		var es_correcta = (respuesta_elegida == respuesta_correcta)
		emit_signal("pregunta_terminada", es_correcta)
		queue_free()

func _on_respuesta_Area2D_A_body_entered(body):
	if body.is_in_group("Jugador"):
		respuesta_elegida = "A"

func _on_respuesta_Area2D_B_body_entered(body):
	if body.is_in_group("Jugador"):
		respuesta_elegida = "B"

func _on_respuesta_Area2D_C_body_entered(body):
	if body.is_in_group("Jugador"):
		respuesta_elegida = "C"
