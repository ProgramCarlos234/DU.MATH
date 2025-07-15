extends Area2D

signal caja_rota(numero: int, posicion: Vector2)

@export var numero: int = 1
@onready var label = $Sprite2D/Label

func set_label(valor: int):
	numero = valor
	label.text = str(valor)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("caja_rota", numero, global_position)
		queue_free()
