extends Area2D

@export var Indicador_mundo: int
@export var TipoDePortal: bool

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var sprite_2d_2: AnimatedSprite2D = $Sprite2D2

func _ready() -> void:
	if TipoDePortal:
		sprite_2d.visible = true
		sprite_2d_2.visible = false
	else:
		sprite_2d_2.visible = true
		sprite_2d.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		body.valor = Indicador_mundo
		print("Entro")
		GameManager.DentroArea = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		GameManager.DentroArea = false
