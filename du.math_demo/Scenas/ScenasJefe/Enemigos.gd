extends CharacterBody2D

@export var velocidad: int = 50
@export var vida: int = 3
@export var dano: int = 1

@onready var jugador: Node2D = get_tree().get_first_node_in_group("Jugador")

func _physics_process(delta: float) -> void:
	if jugador:
		# Perseguir al jugador
		var direccion = (jugador.global_position - global_position).normalized()
		velocity = direccion * velocidad
		move_and_slide()

func recibir_dano(cantidad: int) -> void:
	vida -= cantidad
	if vida <= 0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Jugador"):
		GameManager.VidaJugador -= dano
