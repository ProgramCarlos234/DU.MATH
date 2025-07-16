extends Node

# ======================= #
#     EXPORTS / ESCENAS   #
# ======================= #

@export var enemigo_escena: PackedScene = preload("res://Scenas/ScenasEntorno/EnemigoCajas.tscn")
@export var llave_escena: PackedScene = preload("res://Scenas/ScenasEntorno/llave.tscn")
@export var posicion_llave: NodePath  # Se asigna desde el editor (ej: un Marker2D)

# ======================= #
#        SEÑALES          #
# ======================= #

signal interaction_available(changed: bool, area_name: String)
signal scene_change_requested(scene_path: String)
signal number_changed(new_number)

# ======================= #
#       VARIABLES         #
# ======================= #

var DentroArea: bool = false
var Valor_Nivel1: int
var numero_objetivo: int
var correctas_rotas := 0
var llave_mostrada := false

# ======================= #
#    ESCENAS DISPONIBLES  #
# ======================= #

const MAPA_JUEGO = preload("res://Scenas/ScenasEntorno/Mapa_juego.tscn")
const ENTORNO_RPG = preload("res://Scenas/ScenasEntorno/EntornoRPG.tscn")
const ENTORNO_PLATAFORMAS = preload("res://Scenas/ScenasEntorno/EntornoPlataformas.tscn")
const NIVEL_1_MOVER_CAJAS = preload("res://Scenas/ScenasEntorno/Nivel1_MoverCajas.tscn")

var Scenas: Array = [
	MAPA_JUEGO,
	ENTORNO_RPG,
	ENTORNO_PLATAFORMAS,
	NIVEL_1_MOVER_CAJAS
]

const CORRECTAS_REQUERIDAS = 9

# ======================= #
#    ACCESO A NODOS       #
# ======================= #

@onready var nodo_pos_llave := get_node_or_null(posicion_llave)
@export var nodo_obstaculos_path: NodePath
@onready var nodo_obstaculos := get_node(nodo_obstaculos_path)
# ======================= #
#        _READY           #
# ======================= #

func _ready():
	await get_tree().process_frame  # Asegura que el árbol esté listo
	randomize()
	generate_random_number()
	numero_objetivo = get_current_number()

	configurar_obstaculos()
	conectar_cajas()

# ============================== #
#   GENERACIÓN DE NÚMERO OBJETIVO
# ============================== #

func generate_random_number():
	Valor_Nivel1 = randi() % 9 + 1
	emit_signal("number_changed", Valor_Nivel1)
	return Valor_Nivel1

func get_current_number() -> int:
	return Valor_Nivel1

# ================================= #
#  CONFIGURACIÓN DE LOS OBSTÁCULOS  #
# ================================= #

func configurar_obstaculos():
	for Obstaculo in nodo_obstaculos.get_children():
		var cajas = Obstaculo.get_children()
		if cajas.size() != 4:
			continue

		var correcta_idx = randi() % 4
		var usados = []

		for i in range(4):
			var caja = cajas[i]
			if caja.has_method("set_label"):
				if i == correcta_idx:
					var valor_correcto = numero_objetivo * (randi() % 5 + 1)
					caja.set_label(valor_correcto)
					caja.set_meta("es_correcta", true)
				else:
					var valor_incorrecto = generar_no_multiplo(numero_objetivo, usados)
					caja.set_label(valor_incorrecto)
					caja.set_meta("es_correcta", false)

# ==================================== #
#     GENERADOR DE NÚMERO INCORRECTO   #
# ==================================== #

func generar_no_multiplo(base: int, usados: Array) -> int:
	var intento = 0
	var intentos_max = 100
	var contador = 0

	while contador < intentos_max:
		intento = randi_range(1, 50)
		if intento % base != 0 and intento not in usados:
			usados.append(intento)
			return intento
		contador += 1

	for i in range(1, 51):
		if i % base != 0:
			return i

	return 1

# ======================================= #
#     CONEXIÓN A SEÑALES DE LAS CAJAS     #
# ======================================= #

func conectar_cajas():
	for Obstaculo in nodo_obstaculos.get_children():
		for caja in Obstaculo.get_children():
			if caja.has_signal("caja_rota"):
				caja.connect("caja_rota", Callable(self, "_on_caja_rota"))

# ======================================= #
#     RESPUESTA A LA CAJA ROTA            #
# ======================================= #

func _on_caja_rota(valor: int, posicion: Vector2):
	var caja = get_caja_en_posicion(posicion)
	if caja == null:
		return

	var es_correcta = caja.get_meta("es_correcta", false)

	if es_correcta:
		correctas_rotas += 1
		print("Correctas rotas: ", correctas_rotas)

		if correctas_rotas >= CORRECTAS_REQUERIDAS and not llave_mostrada:
			mostrar_llave()
	else:
		spawn_enemigo(posicion)

# ======================================= #
#    BÚSQUEDA DE LA CAJA POR POSICIÓN     #
# ======================================= #

func get_caja_en_posicion(pos: Vector2) -> Node:
	for Obstaculo in nodo_obstaculos.get_children():
		for caja in Obstaculo.get_children():
			if caja.global_position.distance_to(pos) < 1.0:
				return caja
	return null

# ======================================= #
#      SPAWN DE ENEMIGOS SI FALLA         #
# ======================================= #

func spawn_enemigo(pos: Vector2):
	var enemigo = enemigo_escena.instantiate()
	enemigo.position = pos
	add_child(enemigo)

# ======================================= #
#       MOSTRAR LA LLAVE AL GANAR         #
# ======================================= #

func mostrar_llave():
	if llave_escena == null:
		push_error("La escena de la llave no está asignada.")
		return

	var llave = llave_escena.instantiate()

	if nodo_pos_llave:
		llave.global_position = nodo_pos_llave.global_position
	else:
		llave.global_position = Vector2(0, 0)  # Posición por defecto si no se asignó nodo

	add_child(llave)
	llave_mostrada = true
	print("¡La llave ha aparecido!")
