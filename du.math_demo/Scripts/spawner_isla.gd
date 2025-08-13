extends Node2D

signal npc_toco_jugador(tipo_brain: String)

const BRAIN_EVIL = preload("res://Scenas/ScenasEntorno/BrainEvil.tscn")
const BRAIN_NPC = preload("res://Scenas/ScenasEntorno/BrainNPC.tscn")

# Arrays para gestionar las instancias
var npcsBrains: Array = [BRAIN_EVIL, BRAIN_NPC]
var instancias_activas: Array = []

@export var max_evil_brains: int = 7
@export var max_npc_brains: int = 13
@export var spawn_interval: float = 1.0
@export var despawn_distance: float = 500.0

# Variables internas optimizadas
var spawn_timer: float = 0.0
var cleanup_timer: float = 0.0 # Timer separado para limpieza
var evil_brains_count: int = 0
var npc_brains_count: int = 0
var player_reference: Node2D # Cache del jugador
var cleanup_interval: float = 5.0 # Limpiar cada 5 segundos

func _ready():
	# Cache del jugador
	player_reference = get_tree().get_first_node_in_group("player")
	spawn_initial_brains()

func _process(delta: float) -> void:
	spawn_timer += delta
	cleanup_timer += delta
	
	# Verificar spawn
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		verificar_y_spawnear()
	
	# Limpiar instancias menos frecuentemente para mejor rendimiento
	if cleanup_timer >= cleanup_interval:
		cleanup_timer = 0.0
		limpiar_instancias_lejanas()

# Método principal optimizado
func instanciarCerebros():
	verificar_y_spawnear()

# Spawner inicial optimizado
func spawn_initial_brains():
	for i in range(1):
		spawn_evil_brain()
	for i in range(3):
		spawn_npc_brain()

# Verificación y spawn optimizado
func verificar_y_spawnear():
	# Contar solo cuando sea necesario
	contar_instancias_activas()
	
	# Lógica de spawn optimizada con menos llamadas random
	var spawn_roll = randf()
	
	if evil_brains_count < max_evil_brains and spawn_roll < 0.2:
		spawn_evil_brain()
	elif npc_brains_count < max_npc_brains and spawn_roll >= 0.2:
		spawn_npc_brain()

# Spawn evil brain sin prints
func spawn_evil_brain():
	var nueva_instancia = crear_instancia(BRAIN_EVIL, global_position)
	if nueva_instancia:
		nueva_instancia.add_to_group("evil_brains")
		if nueva_instancia.has_signal("atrapado"):
			nueva_instancia.atrapado.connect(_on_npc_atrapo_jugador.bind("evil"))
		evil_brains_count += 1

# Spawn NPC brain sin prints
func spawn_npc_brain():
	var nueva_instancia = crear_instancia(BRAIN_NPC, global_position)
	if nueva_instancia:
		nueva_instancia.add_to_group("npc_brains")
		if nueva_instancia.has_signal("atrapado"):
			nueva_instancia.atrapado.connect(_on_npc_atrapo_jugador.bind("npc"))
		npc_brains_count += 1

# Callback optimizado sin prints
func _on_npc_atrapo_jugador(tipo: String):
	emit_signal("npc_toco_jugador", tipo)

# Creación de instancia optimizada
func crear_instancia(escena: PackedScene, posicion: Vector2) -> Node2D:
	var instancia = escena.instantiate()
	if instancia:
		get_parent().add_child(instancia)
		instancia.global_position = posicion
		instancias_activas.append(instancia)
		
		if instancia.has_signal("tree_exiting"):
			instancia.tree_exiting.connect(_on_instancia_destruida.bind(instancia))
		
		return instancia
	return null

# Conteo optimizado usando cache
func contar_instancias_activas():
	evil_brains_count = get_tree().get_nodes_in_group("evil_brains").size()
	npc_brains_count = get_tree().get_nodes_in_group("npc_brains").size()

# Limpieza optimizada con menos cálculos
func limpiar_instancias_lejanas():
	if not player_reference or not is_instance_valid(player_reference):
		player_reference = get_tree().get_first_node_in_group("player")
		if not player_reference:
			return
	
	var player_pos = player_reference.global_position
	var despawn_distance_squared = despawn_distance * despawn_distance # Evitar sqrt
	
	for instancia in instancias_activas.duplicate():
		if is_instance_valid(instancia):
			var distance_squared = player_pos.distance_squared_to(instancia.global_position)
			if distance_squared > despawn_distance_squared:
				destruir_instancia(instancia)

# Destrucción sin prints
func destruir_instancia(instancia: Node2D):
	if is_instance_valid(instancia):
		instancias_activas.erase(instancia)
		instancia.queue_free()

# Callback optimizado sin prints
func _on_instancia_destruida(instancia: Node2D):
	instancias_activas.erase(instancia)

# Spawn específico optimizado
func spawn_tipo_especifico(tipo: String, cantidad: int = 1):
	for i in range(cantidad):
		match tipo.to_lower():
			"evil":
				if evil_brains_count < max_evil_brains:
					spawn_evil_brain()
			"npc":
				if npc_brains_count < max_npc_brains:
					spawn_npc_brain()

# Limpieza optimizada
func limpiar_todas_las_instancias():
	for instancia in instancias_activas.duplicate():
		if is_instance_valid(instancia):
			instancia.queue_free()
	instancias_activas.clear()
	evil_brains_count = 0
	npc_brains_count = 0

# Toggle optimizado
func toggle_spawner(activo: bool):
	set_process(activo)

# Ajuste de dificultad optimizado
func ajustar_dificultad(nivel: int):
	match nivel:
		1:
			max_evil_brains = 2
			max_npc_brains = 6
			spawn_interval = 3.0
		2:
			max_evil_brains = 3
			max_npc_brains = 8
			spawn_interval = 2.0
		3:
			max_evil_brains = 4
			max_npc_brains = 10
			spawn_interval = 1.5
		_:
			max_evil_brains = 5
			max_npc_brains = 12
			spawn_interval = 1.0

# Spawn manual optimizado
func spawn_en_posicion_exacta():
	if evil_brains_count < max_evil_brains and npc_brains_count >= max_npc_brains:
		spawn_evil_brain()
	elif npc_brains_count < max_npc_brains:
		spawn_npc_brain()
	elif evil_brains_count < max_evil_brains:
		spawn_evil_brain()

# Info del spawner (solo para debug si es necesario)
func obtener_info_spawner() -> Dictionary:
	return {
		"posicion_spawner": global_position,
		"evil_brains_activos": evil_brains_count,
		"npc_brains_activos": npc_brains_count,
		"instancias_totales": instancias_activas.size(),
		"max_evil": max_evil_brains,
		"max_npc": max_npc_brains,
		"intervalo_spawn": spawn_interval,
		"proporcion_evil_vs_npc": str(evil_brains_count) + ":" + str(npc_brains_count)
	}

# Método de debug comentado (descomenta solo si necesitas debuggear)
# func debug_info():
#	var info = obtener_info_spawner()
#	print("=== SPAWNER DEBUG ===")
#	print("Evil Brains: ", info.evil_brains_activos, "/", info.max_evil)
#	print("NPC Brains: ", info.npc_brains_activos, "/", info.max_npc)
#	print("Proporción: ", info.proporcion_evil_vs_npc)
#	print("==================")
