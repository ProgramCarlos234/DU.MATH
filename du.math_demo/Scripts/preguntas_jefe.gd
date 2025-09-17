extends Node2D

signal pregunta_terminada(correcta: bool)

var preguntas = [
	{"texto":"90 ÷ 15 =", "opciones":["5","6","7"], "correcta":"A"},
	{"texto":"3/4 de 20 =", "opciones":["10","15","12"], "correcta":"B"},
	{"texto":"25% de 80 =", "opciones":["15","20","25"], "correcta":"B"},
	{"texto":"7 × 8 =", "opciones":["54","56","58"], "correcta":"B"},
	{"texto":"12 + 15 =", "opciones":["27","28","26"], "correcta":"A"},
	{"texto":"45 − 17 =", "opciones":["28","29","30"], "correcta":"A"},
	{"texto":"50 ÷ 5 =", "opciones":["10","9","12"], "correcta":"A"},
	{"texto":"2/5 de 50 =", "opciones":["20","25","30"], "correcta":"A"},
	{"texto":"60% de 50 =", "opciones":["25","30","35"], "correcta":"B"},
	{"texto":"Triángulo con lados 3 y 4, \nhallar hipotenusa", "opciones":["5","6","7"], "correcta":"A"},
	{"texto":"Área de un rectángulo 5×8", "opciones":["40","45","50"], "correcta":"A"},
	{"texto":"Perímetro de un cuadrado de lado 7", "opciones":["28","24","21"], "correcta":"A"},
	{"texto":"15 × 4 =", "opciones":["60","55","65"], "correcta":"A"},
	{"texto":"100 − 37 =", "opciones":["63","67","73"], "correcta":"A"},
	{"texto":"3/8 de 32 =", "opciones":["12","11","10"], "correcta":"A"},
	{"texto":"Si un triángulo tiene \nlados 6 y 8, hipotenusa =", "opciones":["10","12","9"], "correcta":"A"},
	{"texto":"20% de 90 =", "opciones":["18","19","20"], "correcta":"A"},
	{"texto":"Suma de 25 + 47", "opciones":["72","71","73"], "correcta":"A"},
	{"texto":"Dividir 81 ÷ 9 =", "opciones":["8","9","10"], "correcta":"B"},
	{"texto":"Área de un triángulo\n base 6 altura 4", "opciones":["12","14","10"], "correcta":"A"}
]

var preguntas_restantes: Array = []
var respuesta_correcta: String = ""
var respuesta_elegida: String = ""

@onready var label_pregunta    = $ProblemaIcono/LabelPregunta
@onready var label_respuesta_a = $Opcion2/LabelA
@onready var label_respuesta_b = $Opcion/LabelB
@onready var label_respuesta_c = $Opcion3/LabelC

@onready var area_a: Area2D = $Opcion2
@onready var area_b: Area2D = $Opcion
@onready var area_c: Area2D = $Opcion3

func _ready():
	randomize()
	# Duplicamos la lista original al inicio para no alterar el array original
	preguntas_restantes = preguntas.duplicate()
	
	area_a.body_entered.connect(_on_area_a_entered)
	area_b.body_entered.connect(_on_area_b_entered)
	area_c.body_entered.connect(_on_area_c_entered)
	
	_mostrar_pregunta()
	set_process_input(true)

func _mostrar_pregunta():
	if preguntas_restantes.size() == 0:
		print("⚠ No hay más preguntas")
		queue_free()
		return
	
	# Elegir índice aleatorio y eliminar la pregunta para que no se repita
	var idx = randi() % preguntas_restantes.size()
	var p = preguntas_restantes[idx]
	preguntas_restantes.remove_at(idx)

	label_pregunta.text    = p["texto"]
	label_respuesta_a.text = "A) " + p["opciones"][0]
	label_respuesta_b.text = "B) " + p["opciones"][1]
	label_respuesta_c.text = "C) " + p["opciones"][2]
	respuesta_correcta     = p["correcta"]
	respuesta_elegida      = ""

func _input(event):
	if event.is_action_pressed("Interactuar") and respuesta_elegida != "":
		var es_correcta = (respuesta_elegida == respuesta_correcta)
		emit_signal("pregunta_terminada", es_correcta)
		queue_free()

func _on_area_a_entered(body):
	if body.is_in_group("Jugador"):
		respuesta_elegida = "A"

func _on_area_b_entered(body):
	if body.is_in_group("Jugador"):
		respuesta_elegida = "B"

func _on_area_c_entered(body):
	if body.is_in_group("Jugador"):
		respuesta_elegida = "C"
