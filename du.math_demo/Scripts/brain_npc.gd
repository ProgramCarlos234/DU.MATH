extends CharacterBody2D
signal atrapado

@export var speed: float = 60.0
@export var detection_radius: float = 8.0

var jugador: Node2D
var navigation_agent: NavigationAgent2D

# Variables anti-atasco
var stuck_timer: float = 0.0
var last_position: Vector2
var stuck_threshold: float = 0.8  # Detectar atasco en 0.8 segundos
var unstuck_force: float = 40.0

# Variables de movimiento suave
var current_velocity: Vector2 = Vector2.ZERO
var acceleration: float = 300.0

func _ready():
	jugador = get_tree().get_first_node_in_group("player")
	if not jugador:
		jugador = get_node("../Jugador")
	
	navigation_agent = $NavigationAgent2D
	
	# 🎯 CONFIGURACIÓN OPTIMIZADA ANTI-ATASCO
	navigation_agent.max_speed = speed
	navigation_agent.path_desired_distance = 3.0      # ⭐ Muy pequeño para seguir mejor
	navigation_agent.target_desired_distance = 6.0    # ⭐ Pequeño para no parar lejos
	navigation_agent.path_max_distance = 500.0
	navigation_agent.radius = 5.0                     # ⭐ Ajustar al tamaño real del sprite
	navigation_agent.avoidance_enabled = true
	navigation_agent.debug_enabled = true
	
	$Area2D.body_entered.connect(_on_body_entered)
	last_position = global_position
	call_deferred("setup_navigation")

func setup_navigation():
	await get_tree().physics_frame
	if jugador and is_instance_valid(jugador):
		navigation_agent.target_position = jugador.global_position

func _physics_process(delta):
	if not jugador or not is_instance_valid(jugador):
		return
	
	# 🚨 DETECCIÓN DE ATASCO MEJORADA
	var movement_distance = global_position.distance_to(last_position)
	
	if movement_distance < 2.0:  # Si se movió menos de 2 pixels
		stuck_timer += delta
	else:
		stuck_timer = 0.0
	
	last_position = global_position
	
	# 🚀 SISTEMA ANTI-ATASCO ACTIVO
	if stuck_timer > stuck_threshold:
		handle_stuck_situation()
		stuck_timer = 0.0
	
	# Actualizar objetivo
	navigation_agent.target_position = jugador.global_position
	
	if navigation_agent.is_navigation_finished():
		# Si termina pero está lejos del jugador, recalcular
		if global_position.distance_to(jugador.global_position) > 20.0:
			navigation_agent.target_position = jugador.global_position
		return
	
	# 🎯 MOVIMIENTO CON ACELERACIÓN SUAVE
	var next_path_position = navigation_agent.get_next_path_position()
	var desired_velocity = global_position.direction_to(next_path_position) * speed
	
	# Interpolación suave de velocidad
	current_velocity = current_velocity.move_toward(desired_velocity, acceleration * delta)
	velocity = current_velocity
	
	move_and_slide()

func handle_stuck_situation():
	print("NPC atascado, aplicando solución...")
	
	# 🎯 ESTRATEGIA 1: Empujón direccional inteligente
	var direction_to_player = global_position.direction_to(jugador.global_position)
	var perpendicular_force = direction_to_player.rotated(PI/2) * unstuck_force
	
	# Alternar entre empujar izquierda y derecha
	if randf() > 0.5:
		perpendicular_force = -perpendicular_force
	
	# 🚀 ESTRATEGIA 2: Teletransporte mínimo si es necesario
	var escape_positions = [
		global_position + Vector2(8, 0),
		global_position + Vector2(-8, 0),
		global_position + Vector2(0, 8),
		global_position + Vector2(0, -8),
		global_position + Vector2(6, 6),
		global_position + Vector2(-6, -6)
	]
	
	# Probar posiciones de escape
	for escape_pos in escape_positions:
		if is_position_valid(escape_pos):
			global_position = escape_pos
			break
	
	# 🔄 ESTRATEGIA 3: Forzar recálculo de ruta
	navigation_agent.target_position = jugador.global_position
	current_velocity = Vector2.ZERO

func is_position_valid(pos: Vector2) -> bool:
	# Usar un pequeño raycast para verificar si la posición es válida
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, pos)
	query.collision_mask = 1  # Ajustar según tus collision layers
	var result = space_state.intersect_ray(query)
	return result.is_empty()

func _on_body_entered(body):
	if body.name == "Jugador":
		emit_signal("atrapado")
		queue_free()
