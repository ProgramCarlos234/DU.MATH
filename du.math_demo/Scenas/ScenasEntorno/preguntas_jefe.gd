extends Node2D

signal pregunta_terminada(correcta: bool)

# Variables de la pregunta
var pregunta_actual: Dictionary = {}
var respuesta_correcta: String = ""
var respuesta_elegida: String = ""
var jugador_dentro: bool = false

# Labels
@onready var label_pregunta    = $ProblemaIcono/LabelPregunta
@onready var label_respuesta_a = $Opcion2/LabelA
@onready var label_respuesta_b = $Opcion/LabelB
@onready var label_respuesta_c = $Opcion3/LabelC

# Áreas
@onready var area_a: Area2D = $Opcion2
@onready var area_b: Area2D = $Opcion
@onready var area_c: Area2D = $Opcion3

func _ready():
	# Confirmar que los labels existen y forzar visibilidad
	var labels_ok := true
	for label in [label_pregunta, label_respuesta_a, label_respuesta_b, label_respuesta_c]:
		if label == null:
			push_error("❌ Label no encontrado en la escena de Pregunta")
			labels_ok = false
		else:
			label.visible = true
			if label.get_parent():
				label.get_parent().visible = true

	# Texto de prueba si hay error
	if not labels_ok:
		if label_pregunta: label_pregunta.text = "ERROR: Falta label"
		if label_respuesta_a: label_respuesta_a.text = "AAA"
		if label_respuesta_b: label_respuesta_b.text = "BBB"
		if label_respuesta_c: label_respuesta_c.text = "CCC"

	# Conectar áreas
	if area_a:
		area_a.body_entered.connect(_on_area_a_entered)
		area_a.body_exited.connect(_on_area_exited)
	if area_b:
		area_b.body_entered.connect(_on_area_b_entered)
		area_b.body_exited.connect(_on_area_exited)
	if area_c:
		area_c.body_entered.connect(_on_area_c_entered)
		area_c.body_exited.connect(_on_area_exited)

	set_process_input(true)

# Asignar la pregunta desde el jefe
func set_pregunta(p: Dictionary):
	if typeof(p) != TYPE_DICTIONARY:
		push_error("❌ La pregunta recibida no es un diccionario")
		return
	pregunta_actual = p
	_mostrar_pregunta()

# Mostrar pregunta y opciones
func _mostrar_pregunta():
	if pregunta_actual.is_empty():
		push_error("⚠ No hay pregunta asignada. Mostrando texto de prueba.")
		if label_pregunta: label_pregunta.text = "¿SE VE ESTO?"
		if label_respuesta_a: label_respuesta_a.text = "AAA"
		if label_respuesta_b: label_respuesta_b.text = "BBB"
		if label_respuesta_c: label_respuesta_c.text = "CCC"
		return

	if label_pregunta:
		label_pregunta.text = pregunta_actual.get("texto", "")
	if label_respuesta_a:
		label_respuesta_a.text = "A) " + pregunta_actual.get("opciones", ["","",""])[0]
	if label_respuesta_b:
		label_respuesta_b.text = "B) " + pregunta_actual.get("opciones", ["","",""])[1]
	if label_respuesta_c:
		label_respuesta_c.text = "C) " + pregunta_actual.get("opciones", ["","",""])[2]

	respuesta_correcta = pregunta_actual.get("correcta", "A")
	respuesta_elegida = ""

# Detección de jugador en cada área
func _on_area_a_entered(body):
	if body.is_in_group("Jugador"):
		jugador_dentro = true
		respuesta_elegida = "A"

func _on_area_b_entered(body):
	if body.is_in_group("Jugador"):
		jugador_dentro = true
		respuesta_elegida = "B"

func _on_area_c_entered(body):
	if body.is_in_group("Jugador"):
		jugador_dentro = true
		respuesta_elegida = "C"

func _on_area_exited(body):
	if body.is_in_group("Jugador"):
		jugador_dentro = false
		respuesta_elegida = ""

# Interacción con la pregunta
func _input(event):
	if jugador_dentro and event.is_action_pressed("Interactuar") and respuesta_elegida != "":
		var correcta := (respuesta_elegida == respuesta_correcta)
		emit_signal("pregunta_terminada", correcta)
		queue_free()
