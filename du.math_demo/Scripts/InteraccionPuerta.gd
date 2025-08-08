extends Area2D

signal Movimiento_Abrir_puerta(Movimiento_Activado: bool)
signal Movimiento_Cerrar_puerta(Movimiento_Activado: bool)

@export var Entrada:bool
@export var Salida:bool

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" and Entrada and GameManager.llave_conseguida == true and Input.is_action_just_pressed("Interactuar"):
		print_debug("Abrir la puerta")
		Movimiento_Abrir_puerta.emit(true) 
			
		if Salida:
				Movimiento_Abrir_puerta.emit(true)
	pass 
