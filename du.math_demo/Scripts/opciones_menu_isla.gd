extends Node2D

@onready var op_1: MenuButton = $Op1
@onready var op_2: MenuButton = $Op2
@onready var op_3: MenuButton = $Op3

var Opciones_Menu_Island : Array
var respuesta_correcta: int
var indice_correcto: int

func _ready() -> void:
	respuesta_correcta = GameManager.Cantidad_Puntaje_Nivel_Island
	
	# Guardamos en un array los 3 botones
	Opciones_Menu_Island = [op_1, op_2, op_3]
	
	# Elegimos aleatoriamente cuál será el botón correcto
	indice_correcto = randi() % 3
	
	# Asignamos la respuesta correcta al botón elegido
	Opciones_Menu_Island[indice_correcto].text = str(respuesta_correcta)
	
	# Generamos las otras dos opciones
	var indices_incorrectos = [0, 1, 2]
	indices_incorrectos.erase(indice_correcto)
	
	for idx in indices_incorrectos:
		var cambio = randi_range(1, 3)
		var es_suma = randf() > 0.5
		var valor_incorrecto = respuesta_correcta + cambio if es_suma else respuesta_correcta - cambio
		
		# Evitar que se repita la respuesta correcta
		if valor_incorrecto == respuesta_correcta:
			valor_incorrecto += 1
		
		Opciones_Menu_Island[idx].text = str(valor_incorrecto)
