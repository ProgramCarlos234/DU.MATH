extends CharacterBody2D

@onready var sprite_enemigo: AnimatedSprite2D = $AnimatedSprite2D
@onready var mordida: AnimatedSprite2D = $Mordida

const SPEED: float = 30.0
var jugador: Node2D
var muerto: bool = false

func _ready() -> void:
	jugador = get_tree().current_scene.get_node_or_null("Jugador")
	mordida.visible = false
	add_to_group("Enemigos")
	velocity = Vector2.ZERO  # 🔹 Inicializar velocity

func _physics_process(delta: float) -> void:
	if muerto or not jugador:
		return

	# Movimiento hacia el jugador
	var direccion = (jugador.global_position - global_position).normalized()
	velocity = direccion * SPEED
	move_and_slide()

	# Voltear sprite solo si hay movimiento horizontal significativo
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
