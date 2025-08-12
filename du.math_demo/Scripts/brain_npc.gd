extends CharacterBody2D
signal atrapado

@export var speed: float = 60.0
@export var detection_radius: float = 8.0

var jugador: Node2D
var navigation_agent: NavigationAgent2D

# Variables anti-atasco optimizadas
var stuck_timer: float = 0.0
var last_position: Vector2
var stuck_threshold: float = 0.8
var unstuck_force: float = 40.0

# Movimiento suave
var current_velocity: Vector2 = Vector2.ZERO
var acceleration: float = 300.0

# Path system optimizado
var path_corregido: Array = []
var current_path_index: int = 0
var margen_paredes: float = 12.0

# Cache para optimización
var jugador_position_cache: Vector2
var navigation_update_timer: float = 0.0
var navigation_update_interval: float = 0.1  # Actualizar navegación cada 0.1s
var space_state: PhysicsDirectSpaceState2D

func _ready():
	# Cache del jugador
	jugador = get_tree().get_first_node_in_group("player")
	if not jugador:
		jugador = get_node("../Jugador")
	
	navigation_agent = $NavigationAgent2D
	space_state = get_world_2d().direct_space_state
	
	# Configuración optimizada
	setup_navigation_agent()
	$Area2D.body_entered.connect(_on_body_entered)
	last_position = global_position
	call_deferred("setup_navigation")

# Configuración del agente de navegación
func setup_navigation_agent():
	navigation_agent.max_speed = speed
	navigation_agent.path_desired_distance = 3.0
	navigation_agent.target_desired_distance = 6.0
	navigation_agent.path_max_distance = 500.0
	navigation_agent.radius = 16.0
	navigation_agent.avoidance_enabled = true
	navigation_agent.debug_enabled = false  # Deshabilitado para mejor rendimiento

func setup_navigation():
	await get_tree().physics_frame
	if jugador and is_instance_valid(jugador):
		jugador_position_cache = jugador.global_position
		navigation_agent.target_position = jugador_position_cache

func _physics_process(delta):
	if not jugador or not is_instance_valid(jugador):
		return
	
	# Actualizar cache del jugador menos frecuentemente
	navigation_update_timer += delta
	if navigation_update_timer >= navigation_update_interval:
		navigation_update_timer = 0.0
		jugador_position_cache = jugador.global_position
		actualizar_objetivo()
	
	# Detección de atasco optimizada
	check_stuck_status(delta)
	
	# Movimiento principal
	ejecutar_movimiento(delta)

# Verificar estado de atasco
func check_stuck_status(delta: float):
	var movement_distance = global_position.distance_squared_to(last_position)
	
	if movement_distance < 4.0:  # 2^2 para evitar sqrt
		stuck_timer += delta
	else:
		stuck_timer = 0.0
	
	last_position = global_position
	
	if stuck_timer > stuck_threshold:
		handle_stuck_situation()
		stuck_timer = 0.0

# Actualizar objetivo de navegación
func actualizar_objetivo():
	if jugador_position_cache.distance_squared_to(navigation_agent.target_position) > 100.0:  # 10^2
		navigation_agent.target_position = jugador_position_cache

# Sistema de movimiento principal
func ejecutar_movimiento(delta: float):
	if navigation_agent.is_navigation_finished():
		if global_position.distance_squared_to(jugador_position_cache) > 400.0:  # 20^2
			navigation_agent.target_position = jugador_position_cache
		return
	
	# Obtener siguiente punto optimizado
	var next_position = obtener_siguiente_punto_optimizado()
	
	if next_position != Vector2.ZERO:
		mover_hacia_punto(next_position, delta)

# Obtener siguiente punto de navegación
func obtener_siguiente_punto_optimizado() -> Vector2:
	# Usar directamente el siguiente punto del NavigationAgent
	var next_path_position = navigation_agent.get_next_path_position()
	
	# Aplicar corrección simple si es necesario
	return aplicar_correccion_rapida(next_path_position)

# Corrección rápida para evitar paredes
func aplicar_correccion_rapida(punto: Vector2) -> Vector2:
	var direccion_jugador = punto.direction_to(jugador_position_cache)
	var punto_corregido = punto + direccion_jugador * 8.0
	
	# Verificación rápida de colisión
	if not hay_colision_rapida(punto, punto_corregido):
		return punto_corregido
	
	return punto

# Verificación rápida de colisión
func hay_colision_rapida(desde: Vector2, hasta: Vector2) -> bool:
	var query = PhysicsRayQueryParameters2D.create(desde, hasta)
	query.collision_mask = 1
	var result = space_state.intersect_ray(query)
	return not result.is_empty()

# Movimiento hacia punto objetivo
func mover_hacia_punto(target: Vector2, delta: float):
	var desired_velocity = global_position.direction_to(target) * speed
	current_velocity = current_velocity.move_toward(desired_velocity, acceleration * delta)
	velocity = current_velocity
	move_and_slide()

# Manejo de situaciones de atasco
func handle_stuck_situation():
	var direction_to_player = global_position.direction_to(jugador_position_cache)
	var perpendicular_force = direction_to_player.rotated(PI/2) * unstuck_force
	
	if randf() > 0.5:
		perpendicular_force = -perpendicular_force
	
	# Posiciones de escape optimizadas
	var escape_positions = [
		global_position + Vector2(8, 0),
		global_position + Vector2(-8, 0),
		global_position + Vector2(0, 8),
		global_position + Vector2(0, -8)
	]
	
	for escape_pos in escape_positions:
		if is_position_valid_fast(escape_pos):
			global_position = escape_pos
			break
	
	# Forzar recálculo
	navigation_agent.target_position = jugador_position_cache
	current_velocity = Vector2.ZERO

# Validación rápida de posición
func is_position_valid_fast(pos: Vector2) -> bool:
	return not hay_colision_rapida(global_position, pos)

# Callback de colisión
func _on_body_entered(body):
	if body.name == "Jugador":
		emit_signal("atrapado")
		queue_free()
