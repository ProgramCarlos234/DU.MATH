extends CharacterBody2D

@onready var sprite_enemigo: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var col_ataque: CollisionShape2D = $AnimatedSprite2D/Ataque/CollisionShape2D

const SPEED = 50.0
const DIRECT_CHASE_DISTANCE = 48.0
const ATAQUE_DISTANCIA = 20.0

var jugador: CharacterBody2D
var atacando = false
var vivo = true

func _ready() -> void:
	jugador = get_tree().current_scene.get_node_or_null("Nivel1/Jugador")

	# Configuración del NavigationAgent2D
	nav_agent.path_desired_distance = 10.0
	nav_agent.target_desired_distance = 12.0
	nav_agent.avoidance_enabled = true

	col_ataque.disabled = true

	# Conexión de señales
	sprite_enemigo.connect("frame_changed", Callable(self, "_on_frame_changed"))
	sprite_enemigo.connect("animation_finished", Callable(self, "_on_animation_finished")) # <- sin args

func _physics_process(delta: float) -> void:
	if not vivo or not jugador:
		return

	# Si está atacando, no moverse hasta terminar animación
	if atacando:
		return

	var dist_al_jugador = global_position.distance_to(jugador.global_position)

	if dist_al_jugador <= ATAQUE_DISTANCIA:
		iniciar_ataque()
	elif dist_al_jugador < DIRECT_CHASE_DISTANCE:
		# Persecución directa
		var direccion = (jugador.global_position - global_position).normalized()
		velocity = velocity.lerp(direccion * SPEED, 0.3)
	else:
		# Navegación por pathfinding
		nav_agent.target_position = jugador.global_position
		if not nav_agent.is_navigation_finished():
			var next_point = nav_agent.get_next_path_position()
			var direccion = (next_point - global_position).normalized()
			velocity = velocity.lerp(direccion * SPEED, 0.2)
		else:
			velocity = Vector2.ZERO

	move_and_slide()

	# Animación según movimiento (con fallback a Idle)
	if not atacando:
		if velocity.length() > 0.1:
			# Volteo + movimiento
			if velocity.x != 0:
				sprite_enemigo.scale.x = sign(velocity.x)
			if sprite_enemigo.animation != "Movement":
				sprite_enemigo.play("Movement")
		else:
			# Si no se mueve, mostrar Idle para no quedar clavado en el último frame del ataque
			if sprite_enemigo.animation != "Idle":
				sprite_enemigo.play("Idle")

func iniciar_ataque() -> void:
	atacando = true
	velocity = Vector2.ZERO
	sprite_enemigo.play("Attack")

func _on_frame_changed() -> void:
	# Activar colisión solo en los frames 2 y 3 de "Attack"
	if sprite_enemigo.animation == "Attack":
		col_ataque.disabled = not (sprite_enemigo.frame in [2, 3])
	else:
		# Seguridad extra: si cambia a otra anim, apagar el collider
		col_ataque.disabled = true

# IMPORTANTE: esta señal NO recibe argumentos en Godot 4
func _on_animation_finished() -> void:
	# Solo reaccionar si la que terminó es "Attack"
	if sprite_enemigo.animation == "Attack":
		col_ataque.disabled = true
		if jugador and vivo:
			var dist_al_jugador = jugador.global_position.distance_to(global_position)
			if dist_al_jugador <= ATAQUE_DISTANCIA:
				# Volver a atacar si sigue cerca
				iniciar_ataque()
				return
		# Si no sigue en rango, salir del estado de ataque y permitir que _physics_process anime Movement/Idle
		atacando = false
