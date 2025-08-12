extends CharacterBody2D

@onready var SpriteEnemigo: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 30.0  # Puedes ajustar la velocidad del enemigo
var jugador: CharacterBody2D

func _ready() -> void:
	jugador = get_tree().current_scene.get_node_or_null("Jugador") # Buscar al jugador en la escena actual

func _physics_process(delta: float) -> void:
	if jugador:
		var direccion = (jugador.global_position - global_position).normalized()
		velocity = direccion * SPEED
		move_and_slide()
	
	# Voltea el sprite según la dirección del movimiento
	if velocity.x < 0:
		SpriteEnemigo.scale.x = -1  # Derecha (asumiendo que -1 es la orientación correcta)
		animated_sprite_2d.play("Movement")
	elif velocity.x > 0:
		SpriteEnemigo.scale.x = 1   # Izquierda
		animated_sprite_2d.play("Movement")

func atacar():
	# Esta función se usará más adelante para hacer daño al jugador
	pass
