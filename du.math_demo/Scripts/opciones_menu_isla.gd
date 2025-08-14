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
	
	# Conectamos las señales de cada botón
	for i in range(Opciones_Menu_Island.size()):
		var menu_button = Opciones_Menu_Island[i]
		# Conectamos la señal pressed con el índice del botón
		menu_button.pressed.connect(_on_button_pressed.bind(i))
	
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

# Función que se ejecuta cuando se presiona cualquier botón
func _on_button_pressed(indice_boton: int):
	# Verificamos si el botón presionado es el correcto
	if indice_boton == indice_correcto:
		# Respuesta correcta - cambiar a pantalla de acierto
		GameManager.Cantidad_Puntaje_Nivel_Island = 0 
		get_tree().change_scene_to_file("res://Scenas/ScenasEntorno/PantallaAcierto.tscn")
		
	else:
		# Respuesta incorrecta - aquí puedes agregar lo que quieras que pase
		print("Respuesta incorrecta")
		# Por ejemplo, cambiar a una pantalla de error:
		# get_tree().change_scene_to_file("res://Scenas/ScenasEntorno/PantallaError.tscn")
