extends Area2D

signal caja_rota(numero: int, posicion: Vector2)

@export var numero: int
@onready var label_caja: Label = $Sprite2D/LabelCaja

var puede_romperse: bool = false

func _ready() -> void:
	set_label(numero)

func set_label(valor: int):
	numero = valor
	label_caja.text = str(valor)

func _on_body_entered(body: Node) -> void:
	if body.name == "Jugador":
		puede_romperse = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Jugador":
		puede_romperse = false

func _process(_delta: float) -> void:
	if puede_romperse and Input.is_action_just_pressed("Interactuar"):
		emit_signal("caja_rota", numero, global_position)
		queue_free()
