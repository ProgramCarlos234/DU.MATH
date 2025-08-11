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
	pass
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador": # Verifica que el cuerpo que entró sea el jugador
		body.valor = Indicador_mundo # Le pasa el valor del indicador al jugador
		GameManager.DentroArea = true # Activa la bandera en el GameManager que permite la interacción
	pass # Replace with function body.

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Jugador": # Verifica que sea el jugador quien salió
		GameManager.DentroArea = false # Desactiva la bandera de interacción en el GameManager
