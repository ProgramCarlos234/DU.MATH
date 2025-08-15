extends Node2D

signal pregunta_terminada(correcta: bool)

var preguntas = [
	{"texto":"90 ÷ 15 =", "opciones":["5","6","7"], "correcta":"A"},
	{"texto":"3/4 de 20 =", "opciones":["10","15","12"], "correcta":"B"},
	{"texto":"25% de 80 =", "opciones":["15","20","25"], "correcta":"B"}
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
	preguntas_restantes = preguntas.duplicate() # duplicar array original
	area_a.body_entered.connect(_on_area_a_entered)
	area_b.body_entered.connect(_on_area_b_entered)
	area_c.body_entered.connect(_on_area_c_entered)
	_mostrar_pregunta()
	set_process_input(true)

func _mostrar_pregunta():
	if preguntas_restantes.is_empty():
		print("⚠ No hay más preguntas")
		queue_free()
		return
	
	var idx = randi() % preguntas_restantes.size()
	var p = preguntas_restantes[idx]
	preguntas_restantes.remove_at(idx)  # eliminar para que no se repita

	label_pregunta.text    = p["texto"]
	label_respuesta_a.text = "A) "+p["opciones"][0]
	label_respuesta_b.text = "B) "+p["opciones"][1]
	label_respuesta_c.text = "C) "+p["opciones"][2]
	respuesta_correcta     = p["correcta"]
	respuesta_elegida      = ""


func _input(event):
	if event.is_action_pressed("Interactuar") and respuesta_elegida != "":
		var es_correcta := (respuesta_elegida == respuesta_correcta)
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
