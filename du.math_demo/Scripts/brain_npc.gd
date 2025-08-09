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

# ⭐ VARIABLES PARA PATH CORREGIDO
var path_corregido: Array = []
var current_path_index: int = 0
var margen_paredes: float = 12.0  # Margen reducido para evitar salir del área navegable

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
	navigation_agent.radius = 16.0                    # ⭐ Radio para margen básico
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
	
	# ⭐ NUEVO SISTEMA: Obtener y corregir el path completo
	actualizar_path_corregido()
	
	# 🎯 MOVIMIENTO USANDO PATH CORREGIDO
	var next_position = obtener_siguiente_punto_corregido()
	
	if next_position != Vector2.ZERO:
		var desired_velocity = global_position.direction_to(next_position) * speed
		# Interpolación suave de velocidad
		current_velocity = current_velocity.move_toward(desired_velocity, acceleration * delta)
		velocity = current_velocity
		move_and_slide()

# ⭐ FUNCIÓN PRINCIPAL: Actualizar el path corregido
func actualizar_path_corregido():
	# Obtener el path original del NavigationAgent
	var path_original = navigation_agent.get_current_navigation_path()
	
	if path_original.size() > 1:
		# Aplicar corrección de margen con validación
		path_corregido = corregir_path_margen_adaptativo(path_original, margen_paredes)
		# Suavizar el path para movimiento más fluido
		path_corregido = suavizar_path(path_corregido, 0.4)
		# Reiniciar el índice del path
		current_path_index = 0

# ⭐ FUNCIÓN: Obtener el siguiente punto del path corregido
func obtener_siguiente_punto_corregido() -> Vector2:
	if path_corregido.size() == 0:
		return Vector2.ZERO
	
	# Si llegamos al punto actual, avanzar al siguiente
	if current_path_index < path_corregido.size():
		var punto_actual = path_corregido[current_path_index]
		var distancia = global_position.distance_to(punto_actual)
		
		# Si estamos cerca del punto, avanzar al siguiente
		if distancia < 8.0:
			current_path_index += 1
		
		# Devolver el punto actual o el siguiente si ya avanzamos
		if current_path_index < path_corregido.size():
			return path_corregido[current_path_index]
	
	return Vector2.ZERO

# ⭐ FUNCIÓN: Verificar si un punto está en área navegable
func es_punto_navegable(punto: Vector2) -> bool:
	# Método usando NavigationServer para verificar si el punto es navegable
	var map = navigation_agent.get_navigation_map()
	var closest_point = NavigationServer2D.map_get_closest_point(map, punto)
	var distance = punto.distance_to(closest_point)
	
	# Si está muy lejos del punto navegable más cercano, no es válido
	return distance < 8.0

# ⭐ FUNCIÓN: Corrección adaptativa que reduce margen si es necesario
func corregir_path_margen_adaptativo(path: Array, margen_inicial: float = 12.0) -> Array:
	var nuevo_path = []
	
	for punto in path:
		var mejor_punto = punto
		var margen_actual = margen_inicial
		
		# Intentar con diferentes márgenes hasta encontrar uno válido
		while margen_actual > 3.0:
			var desplazado = aplicar_correccion_simple(punto, margen_actual)
			
			if es_punto_navegable(desplazado):
				mejor_punto = desplazado
				break
			
			margen_actual -= 3.0  # Reducir margen gradualmente
		
		nuevo_path.append(mejor_punto)
	
	return nuevo_path

# ⭐ FUNCIÓN AUXILIAR: Aplicar corrección simple
func aplicar_correccion_simple(punto: Vector2, margen: float) -> Vector2:
	var direcciones = [
		Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1),
		Vector2(1,1).normalized(), Vector2(-1,1).normalized(),
		Vector2(1,-1).normalized(), Vector2(-1,-1).normalized()
	]
	
	for dir in direcciones:
		var ray = PhysicsRayQueryParameters2D.create(punto, punto + dir * margen)
		var resultado = get_world_2d().direct_space_state.intersect_ray(ray)
		if resultado and "normal" in resultado:
			return punto + resultado.normal * margen
	
	return punto  # Si no encuentra pared, devolver original

# ⭐ FUNCIÓN: Suavizar el path para movimiento más fluido
func suavizar_path(path: Array, smooth_factor: float = 0.4) -> Array:
	if path.size() < 2:
		return path
	
	var smooth_path = []
	for i in range(path.size()-1):
		var a = path[i]
		var b = path[i+1]
		smooth_path.append(a)
		# Agregar punto intermedio suavizado
		smooth_path.append(a.lerp(b, smooth_factor))
	
	smooth_path.append(path[-1])  # Agregar el último punto
	return smooth_path

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
	path_corregido.clear()  # Limpiar path corregido para recalcular

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
