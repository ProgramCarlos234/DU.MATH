extends CharacterBody2D

@onready var sprite_enemigo: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_ataque: AnimatedSprite2D = $Mordida

const SPEED = 30.0
var jugador: CharacterBody2D
var atacando: bool = false

func _ready() -> void:
	jugador = get_tree().current_scene.get_node_or_null("Jugador")
	add_to_group("Enemigos")

	if area_ataque:
		area_ataque.body_entered.connect(_on_area_ataque_body_entered)
		area_ataque.body_exited.connect(_on_area_ataque_body_exited)
	else:
		push_error("⚠ No se encontró el nodo AreaAtaque en el enemigo")

func _physics_process(delta: float) -> void:
	if jugador and not atacando:
		var direccion = (jugador.global_position - global_position).normalized()
		velocity = direccion * SPEED
		move_and_slide()

	if velocity.x < 0:
		sprite_enemigo.scale.x = 1
	elif velocity.x > 0:
		sprite_enemigo.scale.x = -1

func _on_area_ataque_body_entered(body: Node) -> void:
	if body.is_in_group("Jugador"):
		atacando = true
		velocity = Vector2.ZERO
		if sprite_enemigo.sprite_frames and sprite_enemigo.sprite_frames.has_animation("Mordida"):
			sprite_enemigo.play("Mordida")
		else:
			push_warning("⚠ La animación 'Mordida' no existe en este sprite")

func _on_area_ataque_body_exited(body: Node) -> void:
	if body.is_in_group("Jugador"):
		atacando = false
