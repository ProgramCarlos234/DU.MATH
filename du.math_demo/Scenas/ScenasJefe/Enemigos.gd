extends CharacterBody2D

@onready var SpriteEnemigo: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 30.0
var jugador: CharacterBody2D

func _ready() -> void:
	jugador = get_tree().current_scene.get_node_or_null("Jugador")
	add_to_group("Enemigos") # ✅ Para que el jugador pueda reconocerlo en el ataque

func _physics_process(delta: float) -> void:
	if jugador:
		var direccion = (jugador.global_position - global_position).normalized()
		velocity = direccion * SPEED
		move_and_slide()
	
	# Voltear sprite
	if velocity.x < 0:
		SpriteEnemigo.scale.x = -1
	elif velocity.x > 0:
		SpriteEnemigo.scale.x = 1
