extends Node2D

@export var Nodo_Final: NodePath
@export var Velocidad: int = 100

signal movimiento_terminado

var en_movimiento := false
var destino: Vector2

func _ready() -> void:
	if has_node(Nodo_Final):
		destino = get_node(Nodo_Final).global_position
	else:
		push_error("Nodo_Final no asignado correctamente.")

func iniciar_movimiento():
	en_movimiento = true

func _process(delta):
	if not en_movimiento:
		return

	var dir = (destino - global_position).normalized()
	global_position += dir * Velocidad * delta

	if global_position.distance_to(destino) < 2:  # margen de tolerancia
		global_position = destino
		en_movimiento = false
		emit_signal("movimiento_terminado")
