extends CharacterBody2D

const SPEED = 30.0  # Puedes ajustar la velocidad del enemigo

var jugador: CharacterBody2D

func _ready() -> void:
	jugador = get_tree().current_scene.get_node_or_null("Jugador") # Buscar al jugador en la escena actual

	if jugador == null:
		push_error("No se encontró al nodo 'Jugador' en la escena actual.")

func _physics_process(delta: float) -> void:
	if jugador:
		var direccion = (jugador.global_position - global_position).normalized()
		velocity = direccion * SPEED
		move_and_slide()

func atacar():
	# Esta función se usará más adelante para hacer daño al jugador
	pass
