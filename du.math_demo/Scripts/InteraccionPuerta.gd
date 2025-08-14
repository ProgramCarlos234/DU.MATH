extends Area2D

signal Movimiento_Abrir_puerta(Movimiento_Activado: bool)
signal Movimiento_Cerrar_puerta(Movimiento_Activado: bool)

@export var Entrada: bool
@export var Salida: bool

var jugador_dentro: bool = false

func _process(delta: float) -> void:
	if jugador_dentro and Input.is_action_just_pressed("Interactuar"):
		if Entrada and GameManager.llave_conseguida:
			print_debug("Abrir puerta de entrada")
			Movimiento_Abrir_puerta.emit(true)

		elif Salida:
			print_debug("Abrir puerta de salida")
			Movimiento_Cerrar_puerta.emit(true)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador":
		jugador_dentro = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Jugador":
		jugador_dentro = false
