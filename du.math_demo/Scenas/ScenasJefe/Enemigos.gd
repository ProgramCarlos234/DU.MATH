extends CharacterBody2D

@onready var sprite_enemigo: AnimatedSprite2D = $AnimatedSprite2D
@onready var mordida: AnimatedSprite2D = $Mordida

const SPEED = 30.0
var jugador: CharacterBody2D
var muerto: bool = false # Evita que el enemigo siga moviéndose después de morir

func _ready() -> void:
	jugador = get_tree().current_scene.get_node_or_null("Jugador")
	mordida.visible = false
	add_to_group("Enemigos") # 🔹 Lo añade automáticamente al grupo

func _physics_process(delta: float) -> void:
	if muerto:
		return # No se mueve si está muerto

	if jugador:
		var direccion = (jugador.global_position - global_position).normalized()
		velocity = direccion * SPEED
		move_and_slide()
	
	# Voltear sprite
	if velocity.x < 0:
		sprite_enemigo.scale.x = 1
		mordida.scale.x = 1
		sprite_enemigo.play("Walk")
	elif velocity.x > 0:
		sprite_enemigo.scale.x = -1
		mordida.scale.x = -1
		sprite_enemigo.play("Walk")

func morir():
	if muerto:
		return
	muerto = true
	sprite_enemigo.play("Death") # Asegúrate de tener esta animación
	await sprite_enemigo.animation_finished
	queue_free()

func _on_mordida_animation_finished() -> void:
	mordida.visible = false
	sprite_enemigo.visible = true
