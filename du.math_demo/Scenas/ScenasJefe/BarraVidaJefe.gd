extends Node2D

@onready var barra: ProgressBar = get_node_or_null("ProgressBar")
@onready var label: Label = get_node_or_null("Label")

var vida_max: int = 100
var vida_actual: int = 100

func _ready():
	if barra == null:
		push_error("❌ No se encontró el nodo ProgressBar. Verifica la ruta o el nombre del nodo.")
		return
	
	if label == null:
		push_error("❌ No se encontró el nodo Label. Verifica la ruta o el nombre del nodo.")
		return
	
	configurar_vida(vida_max)


func configurar_vida(max_vida: int):
	vida_max = max_vida
	vida_actual = max_vida
	
	if barra:
		barra.min_value = 0
		barra.max_value = vida_max
		barra.value = vida_actual
	
	actualizar_label()


func actualizar_vida(nueva_vida: int):
	vida_actual = clamp(nueva_vida, 0, vida_max)
	
	if barra:
		barra.value = vida_actual
	
	actualizar_label()


func actualizar_label():
	if label:
		label.text = str(vida_actual) + " / " + str(vida_max)
