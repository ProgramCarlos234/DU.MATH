extends CharacterBody2D

@onready var sprite_enemigo: AnimatedSprite2D = $AnimatedSprite2D
@onready var mordida: AnimatedSprite2D = $Mordida

const SPEED: float = 30.0
var jugador: Node2D
var muerto: bool = false
const MAX_DISTANCIA: float = 800.0  # 🔹 Rango máximo de persecución

func _ready() -> void:
	jugador = get_tree().current_scene.get_node_or_null("Jugador")  # 🔹 Mantengo tu referencia original
	mordida.visible = false
	add_to_group("Enemigos")
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if muerto or not jugador or not jugador.is_inside_tree():
		velocity = Vector2.ZERO       # 🔹 Detener si no hay jugador
		move_and_slide()
		return

	# Verificar distancia al jugador
	var distancia = global_position.distance_to(jugador.global_position)
	if distancia > MAX_DISTANCIA:
		velocity = Vector2.ZERO
	else:
		# Siempre seguir al jugador
		var direccion = (jugador.global_position - global_position).normalized()
		velocity = direccion * SPEED

	move_and_slide()

	# Animación y flip
	if abs(velocity.x) > 0.01:
		var signo = 1 if velocity.x < 0 else -1
		sprite_enemigo.scale.x = signo
		mordida.scale.x = signo
		sprite_enemigo.play("Walk")

func morir() -> void:
	if muerto:
		return
	muerto = true
	sprite_enemigo.play("Death")
	await sprite_enemigo.animation_finished
	queue_free()

func _on_mordida_animation_finished() -> void:
	mordida.visible = false
	sprite_enemigo.visible = true
