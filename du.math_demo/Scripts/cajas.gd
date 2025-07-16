extends Area2D

# Señal que se emite cuando la caja es rota por el jugador
signal caja_rota(numero: int, posicion: Vector2)

# Número que representa el valor visible en la caja
@export var numero: int

# Acceso al texto de la caja
@onready var label_caja: Label = $Sprite2D/LabelCaja

func _ready() -> void:
	add_to_group("Caja")  # Por si lo necesitas después

# Asigna el número a mostrar en la caja
func set_label(valor: int):
	numero = valor
	label_caja.text = str(valor)

# Detecta cuando el jugador hace clic sobre la caja
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("caja_rota", numero, global_position)
		queue_free()  # Se elimina tras ser rota
