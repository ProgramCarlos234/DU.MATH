extends Node2D

# Variables para el sistema de puntaje
var puntaje_real: int = 0
var ultimo_valor: int = 0
var penultimo_valor: int = 0

# Referencias a los nodos de texto
@onready var texto_operacion: Label = $Jugador/TextoOperacion
@onready var texto_operacion2: Label = $Jugador/TextoOperacion2
@onready var jugador: Node2D = $Jugador

# Array de spawners y sus configuraciones
var spawners: Array[Node2D] = []
var spawner_paths: Array[String] = [
	"SpawnerIsla",
	"SpawnerIsla2", 
	"NivelNodoIsla/SpawnerIsla3",
	"NivelNodoIsla/SpawnerIsla4",
	"NivelNodoIsla/SpawnerIsla5",
	"NivelNodoIsla/SpawnerIsla6"
]

# Sistema de optimización de NPCs
var npcs_activos: Array[Node2D] = []
var spawner_npc_map: Dictionary = {}
var distancia_culling: float = 1500.0
var distancia_respawn: float = 1200.0
var timer_optimizacion: Timer
var intervalo_check: float = 0.5

# Configuración de rendimiento
var max_npcs_por_frame: int = 3
var contador_frame: int = 0

func _ready():
	# Inicializar referencia del jugador
	_inicializar_jugador()
	
	# Inicializar texto labels
	_inicializar_labels()
	
	# Inicializar spawners usando el array
	_inicializar_spawners()
	
	# Configurar sistema de optimización
	_configurar_sistema_optimizacion()
	
	# Mostrar texto inicial
	mostrar_valor_inicial()

func _inicializar_jugador():
	if not jugador:
		jugador = find_child("Jugador", true, false)
	
	if not jugador:
		print("Advertencia: No se encontró el nodo Jugador")

func _inicializar_labels():
	# Buscar labels si no están asignados
	if not texto_operacion:
		texto_operacion = find_child("TextoOperacion", true, false)
	
	if not texto_operacion2:
		texto_operacion2 = find_child("TextoOperacion2", true, false)

func _inicializar_spawners():
	# Limpiar arrays por si acaso
	spawners.clear()
	spawner_npc_map.clear()
	
	# Iterar sobre los paths y configurar cada spawner
	for path in spawner_paths:
		var spawner = get_node_or_null(path)
		
		# Si no se encuentra directamente, buscar como hijo
		if not spawner:
			spawner = find_child(path.get_file(), true, false)
		
		# Si se encontró el spawner, agregarlo al array y conectar señal
		if spawner:
			spawners.append(spawner)
			_conectar_spawner(spawner)
			
			# Inicializar mapeo de spawner a NPCs
			spawner_npc_map[spawner] = []
		else:
			print("Advertencia: No se pudo encontrar el spawner: ", path)

func _configurar_sistema_optimizacion():
	# Crear timer para optimización
	timer_optimizacion = Timer.new()
	timer_optimizacion.wait_time = intervalo_check
	timer_optimizacion.timeout.connect(_optimizar_npcs)
	timer_optimizacion.autostart = true
	add_child(timer_optimizacion)

func _conectar_spawner(spawner: Node2D):
	# Conectar la señal si existe
	if spawner.has_signal("npc_toco_jugador"):
		# Verificar si ya está conectado para evitar conexiones duplicadas
		if not spawner.npc_toco_jugador.is_connected(_on_npc_toco_jugador):
			spawner.npc_toco_jugador.connect(_on_npc_toco_jugador)
	
	# Conectar señal de NPC creado si existe
	if spawner.has_signal("npc_creado"):
		if not spawner.npc_creado.is_connected(_on_npc_creado):
			spawner.npc_creado.connect(_on_npc_creado)

func _process(delta: float) -> void:
	# Optimización: solo actualizar si el valor cambió
	var nuevo_puntaje = GameManager.Cantidad_Puntaje_Nivel_Island
	if puntaje_real != nuevo_puntaje:
		puntaje_real = nuevo_puntaje
	
	# Resetear contador de frame
	contador_frame = 0

# Sistema de optimización principal
func _optimizar_npcs():
	if not jugador:
		return
	
	var posicion_jugador = jugador.global_position
	var npcs_para_eliminar: Array[Node2D] = []
	var spawners_para_activar: Array[Node2D] = []
	
	# Verificar NPCs activos para culling
	for npc in npcs_activos:
		if not is_instance_valid(npc):
			npcs_activos.erase(npc)
			continue
		
		var distancia = posicion_jugador.distance_to(npc.global_position)
		
		if distancia > distancia_culling:
			npcs_para_eliminar.append(npc)
	
	# Verificar spawners para respawn
	for spawner in spawners:
		if not is_instance_valid(spawner):
			continue
		
		var distancia_spawner = posicion_jugador.distance_to(spawner.global_position)
		var npcs_spawner = spawner_npc_map.get(spawner, [])
		
		# Filtrar NPCs válidos del spawner
		npcs_spawner = npcs_spawner.filter(func(npc): return is_instance_valid(npc))
		spawner_npc_map[spawner] = npcs_spawner
		
		# Si no hay NPCs activos en este spawner y está cerca, activar respawn
		if npcs_spawner.is_empty() and distancia_spawner <= distancia_respawn:
			spawners_para_activar.append(spawner)
	
	# Ejecutar eliminaciones de forma escalonada
	_ejecutar_culling_escalonado(npcs_para_eliminar)
	
	# Ejecutar respawn de forma escalonada
	_ejecutar_respawn_escalonado(spawners_para_activar)

func _ejecutar_culling_escalonado(npcs_para_eliminar: Array[Node2D]):
	var procesados = 0
	
	for npc in npcs_para_eliminar:
		if procesados >= max_npcs_por_frame:
			break
		
		_eliminar_npc(npc)
		procesados += 1

func _ejecutar_respawn_escalonado(spawners_para_activar: Array[Node2D]):
	var procesados = 0
	
	for spawner in spawners_para_activar:
		if procesados >= max_npcs_por_frame:
			break
		
		_solicitar_respawn(spawner)
		procesados += 1

func _eliminar_npc(npc: Node2D):
	if not is_instance_valid(npc):
		return
	
	# Remover de lista de NPCs activos
	npcs_activos.erase(npc)
	
	# Remover del mapeo de spawner
	for spawner in spawner_npc_map:
		var npcs_spawner = spawner_npc_map[spawner]
		if npc in npcs_spawner:
			npcs_spawner.erase(npc)
			break
	
	# Eliminar el NPC
	npc.queue_free()

func _solicitar_respawn(spawner: Node2D):
	if not is_instance_valid(spawner):
		return
	
	# Verificar si el spawner tiene método de respawn
	if spawner.has_method("crear_npc"):
		spawner.crear_npc()
	elif spawner.has_method("spawn_npc"):
		spawner.spawn_npc()
	elif spawner.has_method("respawn"):
		spawner.respawn()

# Función llamada cuando un spawner crea un NPC
func _on_npc_creado(npc: Node2D, spawner: Node2D):
	if not is_instance_valid(npc) or not is_instance_valid(spawner):
		return
	
	# Agregar a lista de NPCs activos
	if not npc in npcs_activos:
		npcs_activos.append(npc)
	
	# Agregar al mapeo del spawner
	if spawner in spawner_npc_map:
		var npcs_spawner = spawner_npc_map[spawner]
		if not npc in npcs_spawner:
			npcs_spawner.append(npc)
	
	# Conectar señal de eliminación del NPC si existe
	if npc.has_signal("tree_exited"):
		npc.tree_exited.connect(_on_npc_eliminado.bind(npc))

func _on_npc_eliminado(npc: Node2D):
	# Limpiar referencias cuando un NPC es eliminado
	npcs_activos.erase(npc)
	
	for spawner in spawner_npc_map:
		spawner_npc_map[spawner].erase(npc)

func _on_npc_toco_jugador(tipo_brain: String):
	var valor_obtenido: int = 0
	
	# Calcular valor según el tipo de Brain
	match tipo_brain:
		"npc":
			valor_obtenido = randi_range(1, 9)
		"evil":
			valor_obtenido = -randi_range(1, 5)
		_:
			return
	
	# Actualizar valores
	penultimo_valor = ultimo_valor
	ultimo_valor = valor_obtenido
	
	# Actualizar puntaje real
	GameManager._CalcularValor_Nivel_Island(valor_obtenido)
	
	# Mostrar valores en labels
	mostrar_valores_en_labels()

func mostrar_valores_en_labels():
	# Optimización: usar operador ternario para simplificar
	if texto_operacion:
		texto_operacion.text = "+" + str(ultimo_valor) if ultimo_valor > 0 else str(ultimo_valor)
	
	if texto_operacion2:
		if penultimo_valor == 0:
			texto_operacion2.text = ""
		else:
			texto_operacion2.text = "+" + str(penultimo_valor) if penultimo_valor > 0 else str(penultimo_valor)

func mostrar_valor_inicial():
	if texto_operacion:
		texto_operacion.text = ""
	if texto_operacion2:
		texto_operacion2.text = ""

func mostrar_operacion_real():
	if texto_operacion:
		texto_operacion.text = "Total: " + str(puntaje_real)

# Funciones de configuración del sistema de optimización
func configurar_distancias(culling: float, respawn: float):
	distancia_culling = culling
	distancia_respawn = respawn

func configurar_intervalo_optimizacion(intervalo: float):
	intervalo_check = intervalo
	if timer_optimizacion:
		timer_optimizacion.wait_time = intervalo

func configurar_max_npcs_por_frame(cantidad: int):
	max_npcs_por_frame = cantidad

# Funciones de utilidad
func obtener_puntaje_real() -> int:
	return puntaje_real

func obtener_ultimo_valor() -> int:
	return ultimo_valor

func obtener_penultimo_valor() -> int:
	return penultimo_valor

func obtener_cantidad_npcs_activos() -> int:
	return npcs_activos.size()

func obtener_npcs_por_spawner(spawner: Node2D) -> Array:
	return spawner_npc_map.get(spawner, [])

func reiniciar_puntaje():
	puntaje_real = 0
	ultimo_valor = 0
	penultimo_valor = 0
	mostrar_valor_inicial()

func limpiar_todos_los_npcs():
	# Eliminar todos los NPCs activos
	for npc in npcs_activos:
		if is_instance_valid(npc):
			npc.queue_free()
	
	npcs_activos.clear()
	
	# Limpiar mapeo de spawners
	for spawner in spawner_npc_map:
		spawner_npc_map[spawner].clear()

# Función para agregar spawners dinámicamente
func agregar_spawner(path: String):
	spawner_paths.append(path)
	var spawner = get_node_or_null(path)
	if spawner:
		spawners.append(spawner)
		_conectar_spawner(spawner)
		spawner_npc_map[spawner] = []

# Función para obtener información de spawners
func obtener_cantidad_spawners() -> int:
	return spawners.size()

func obtener_spawners_activos() -> Array[Node2D]:
	return spawners

func obtener_estadisticas_optimizacion() -> Dictionary:
	return {
		"npcs_activos": npcs_activos.size(),
		"spawners_total": spawners.size(),
		"distancia_culling": distancia_culling,
		"distancia_respawn": distancia_respawn,
		"intervalo_check": intervalo_check
	}

func _on_timer_timeout() -> void:
	pass # Replace with function body.
