extends Node2D

signal npc_toco_jugador(tipo_brain: String)

const BRAIN_EVIL = preload("res://Scenas/ScenasEntorno/BrainEvil.tscn")
const BRAIN_NPC = preload("res://Scenas/ScenasEntorno/BrainNPC.tscn")

# Arrays para gestionar las instancias
var npcsBrains: Array = [BRAIN_EVIL, BRAIN_NPC]
var instancias_activas: Array = []

@export var max_evil_brains: int = 5
@export var max_npc_brains: int = 8
@export var spawn_interval: float = 2.0
@export var despawn_distance: float = 500.0

# Variables internas
var spawn_timer: float = 0.0
var evil_brains_count: int = 0
var npc_brains_count: int = 0

func _ready():
	# Spawner inicial
	spawn_initial_brains()

func _process(delta: float) -> void:
	spawn_timer += delta
	
	# Verificar si es momento de spawnear
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		verificar_y_spawnear()
	
	# Limpiar instancias que están muy lejos
	limpiar_instancias_lejanas()

# Método principal para instanciar cerebros
func instanciarCerebros():
	verificar_y_spawnear()

# Spawner inicial para poblar el mundo (más NPCs que EvilBrains)
func spawn_initial_brains():
	# Spawnear menos evil brains inicialmente
	for i in range(1):
		spawn_evil_brain()
	# Spawnear más NPCs inicialmente
	for i in range(3):
		spawn_npc_brain()

# Verificar límites y spawnear según sea necesario
func verificar_y_spawnear():
	# Contar instancias activas
	contar_instancias_activas()
	
	# Spawnear evil brains si es necesario (menor probabilidad)
	if evil_brains_count < max_evil_brains:
		if randf() < 0.2: # 20% de probabilidad (menor que antes)
			spawn_evil_brain()
	
	# Spawnear NPC brains si es necesario (mayor probabilidad)
	if npc_brains_count < max_npc_brains:
		if randf() < 0.8: # 80% de probabilidad (mayor que antes)
			spawn_npc_brain()

# Spawnear un cerebro evil con tipo específico
func spawn_evil_brain():
	var nueva_instancia = crear_instancia(BRAIN_EVIL, global_position)
	if nueva_instancia:
		nueva_instancia.add_to_group("evil_brains")
		# Conectar con el tipo "evil"
		if nueva_instancia.has_signal("atrapado"):
			nueva_instancia.atrapado.connect(_on_npc_atrapo_jugador.bind("evil"))
		evil_brains_count += 1
		print("Evil Brain spawneado en posición exacta del spawner: ", global_position)

#  Spawnear un cerebro NPC con tipo específico
func spawn_npc_brain():
	var nueva_instancia = crear_instancia(BRAIN_NPC, global_position)
	if nueva_instancia:
		nueva_instancia.add_to_group("npc_brains")
		# Conectar con el tipo "npc"
		if nueva_instancia.has_signal("atrapado"):
			nueva_instancia.atrapado.connect(_on_npc_atrapo_jugador.bind("npc"))
		npc_brains_count += 1
		print("NPC Brain spawneado en posición exacta del spawner: ", global_position)

# Callback que recibe el tipo de brain
func _on_npc_atrapo_jugador(tipo: String):
	print("¡Un ", tipo, " brain tocó al jugador desde el spawner!")
	# Emitir señal con el tipo al nodo principal
	emit_signal("npc_toco_jugador", tipo)

# Crear una instancia y añadirla al escenario en posición exacta
func crear_instancia(escena: PackedScene, posicion: Vector2) -> Node2D:
	var instancia = escena.instantiate()
	if instancia:
		get_parent().add_child(instancia)
		# Establecer la posición exacta del spawner
		instancia.global_position = posicion
		instancias_activas.append(instancia)
		
		# Conectar señal de muerte si existe
		if instancia.has_signal("tree_exiting"):
			instancia.tree_exiting.connect(_on_instancia_destruida.bind(instancia))
		
		return instancia
	return null

# Contar instancias activas por tipo
func contar_instancias_activas():
	evil_brains_count = get_tree().get_nodes_in_group("evil_brains").size()
	npc_brains_count = get_tree().get_nodes_in_group("npc_brains").size()

# Limpiar instancias que están muy lejas del spawner
func limpiar_instancias_lejanas():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	for instancia in instancias_activas.duplicate():
		if is_instance_valid(instancia):
			var distancia = player.global_position.distance_to(instancia.global_position)
			if distancia > despawn_distance:
				destruir_instancia(instancia)

# Destruir una instancia específica
func destruir_instancia(instancia: Node2D):
	if is_instance_valid(instancia):
		instancias_activas.erase(instancia)
		instancia.queue_free()
		print("Instancia destruida por distancia")

# Callback cuando una instancia es destruida
func _on_instancia_destruida(instancia: Node2D):
	instancias_activas.erase(instancia)
	print("Instancia destruida")

# Método para spawnear un tipo específico en posición exacta del spawner
func spawn_tipo_especifico(tipo: String, cantidad: int = 1):
	for i in range(cantidad):
		match tipo.to_lower():
			"evil":
				if evil_brains_count < max_evil_brains:
					spawn_evil_brain()
			"npc":
				if npc_brains_count < max_npc_brains:
					spawn_npc_brain()
			_:
				print("Tipo no reconocido: ", tipo)

# Método para limpiar todas las instancias
func limpiar_todas_las_instancias():
	for instancia in instancias_activas.duplicate():
		if is_instance_valid(instancia):
			instancia.queue_free()
	instancias_activas.clear()
	evil_brains_count = 0
	npc_brains_count = 0

# Método para pausar/reanudar el spawner
func toggle_spawner(activo: bool):
	set_process(activo)

# Método para ajustar la dificultad dinámicamente (manteniendo menos EvilBrains)
func ajustar_dificultad(nivel: int):
	match nivel:
		1:
			max_evil_brains = 2    # Menos evil brains
			max_npc_brains = 6     # Más NPCs
			spawn_interval = 3.0
		2:
			max_evil_brains = 3    # Menos evil brains
			max_npc_brains = 8     # Más NPCs
			spawn_interval = 2.0
		3:
			max_evil_brains = 4    # Menos evil brains
			max_npc_brains = 10    # Más NPCs
			spawn_interval = 1.5
		_:
			max_evil_brains = 5    # Menos evil brains
			max_npc_brains = 12    # Más NPCs
			spawn_interval = 1.0

# Método para spawnear manualmente en posición exacta
func spawn_en_posicion_exacta():
	print("Spawneando en posición exacta del spawner: ", global_position)
	
	# Decidir qué spawnear basándose en las proporciones
	if evil_brains_count < max_evil_brains and npc_brains_count >= max_npc_brains:
		spawn_evil_brain()
	elif npc_brains_count < max_npc_brains:
		spawn_npc_brain()
	elif evil_brains_count < max_evil_brains:
		spawn_evil_brain()

# Debug: Información del spawner
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

# Método para mostrar información en consola
func debug_info():
	var info = obtener_info_spawner()
	print("=== SPAWNER DEBUG ===")
	print("Evil Brains: ", info.evil_brains_activos, "/", info.max_evil)
	print("NPC Brains: ", info.npc_brains_activos, "/", info.max_npc)
	print("Proporción: ", info.proporcion_evil_vs_npc)
	print("==================")
