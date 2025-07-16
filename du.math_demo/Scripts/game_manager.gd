extends Node

# ======================== #
#     EXPORTS (Editor)     #
# ======================== #

@export var tilemap_layer: TileMapLayer          # Solo la capa del suelo
@export var caja_escena: PackedScene             # Referencia a Caja.tscn
@export var enemigo_escena: PackedScene          # Referencia a Enemigo.tscn
@export var llave_escena: PackedScene            # Referencia a Llave.tscn
@export var portal_path: NodePath                # Ruta al nodo del portal ya presente en la escena

# ======================== #
#       SEÑALES GLOBALES   #
# ======================== #

signal interaction_available(changed: bool, area_name: String)
signal scene_change_requested(scene_path: String)
signal number_changed(new_number)

# ======================== #
#     VARIABLES DE CONTROL #
# ======================== #

var DentroArea: bool = false
var Valor_Nivel1: int

var numero_objetivo: int
var correctas_rotas := 0
var posiciones_validas: Array[Vector2] = []

# ======================== #
#     ESCENAS DEL JUEGO    #
# ======================== #

const MAPA_JUEGO = preload("res://Scenas/ScenasEntorno/Mapa_juego.tscn")             # 0
const ENTORNO_RPG = preload("res://Scenas/ScenasEntorno/EntornoRPG.tscn")            # 1
const ENTORNO_PLATAFORMAS = preload("res://Scenas/ScenasEntorno/EntornoPlataformas.tscn")  # 2
const NIVEL_1_MOVER_CAJAS = preload("res://Scenas/ScenasEntorno/Nivel1_MoverCajas.tscn")   # 3

var Scenas: Array = [
	MAPA_JUEGO, ENTORNO_RPG, ENTORNO_PLATAFORMAS, NIVEL_1_MOVER_CAJAS
]

const TOTAL_CAJAS = 20
const CORRECTAS_REQUERIDAS = 10

# ======================== #
#         INICIO           #
# ======================== #

func _ready():
	randomize()
	generate_random_number()

	numero_objetivo = get_current_number()
	# posiciones_validas = obtener_tiles_validos()
	posiciones_validas.shuffle()
	colocar_cajas()

# ======================== #
#  GENERADOR DE NÚMERO     #
# ======================== #

func generate_random_number():
	Valor_Nivel1 = randi() % 9 + 1  # Número entre 1 y 9
	emit_signal("number_changed", Valor_Nivel1)
	return Valor_Nivel1

func get_current_number() -> int:
	return Valor_Nivel1

# ======================== #
#   CAMBIO DE ESCENAS      #
# ======================== #

func _AbrirEscenas(valor: int):
	if valor >= 0 and valor < Scenas.size():
		get_tree().change_scene_to_packed(Scenas[valor])
	else:
		push_error("Índice de escena inválido: " + str(valor))

# ======================== #
#  DETECCIÓN DE TILES      #
# ======================== #

"""
func obtener_tiles_validos() -> Array[Vector2]:
	var posiciones: Array[Vector2] = []
	var rect = tilemap_layer.get_used_rect()

	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var coord := Vector2i(x, y)

			# get_cell_tile returns the tile info si hay tile en esa celda
			var tile = tilemap_layer.get_cell_tile(coord)
			if tile:  # No es null ni vacío
				var world_pos = tilemap_layer.to_global(tilemap_layer.map_to_local(coord)) + tilemap_layer.get_tile_size() / 2
				posiciones.append(world_pos)

	return posiciones
"""
# ======================== #
#   INSTANCIAR OBJETOS     #
# ======================== #

func colocar_cajas():
	var correctas = 0

	for i in range(min(TOTAL_CAJAS, posiciones_validas.size())):
		var caja = caja_escena.instantiate()
		var posicion = posiciones_validas[i]

		var valor: int
		if correctas < CORRECTAS_REQUERIDAS:
			valor = numero_objetivo * (randi() % 9 + 1)
			correctas += 1
		else:
			while true:
				valor = randi() % 99 + 1
				if valor % numero_objetivo != 0:
					break

		caja.set_label(valor)
		caja.connect("caja_rota", Callable(self, "_on_caja_rota"))
		caja.position = posicion
		add_child(caja)

# ======================== #
#      EVENTOS CAJAS       #
# ======================== #

func _on_caja_rota(numero: int, posicion: Vector2):
	if numero % numero_objetivo == 0:
		correctas_rotas += 1
		if correctas_rotas == CORRECTAS_REQUERIDAS:
			spawn_llave(posicion)
	else:
		spawn_enemigo(posicion)

# ======================== #
#     LLAVE Y ENEMIGO      #
# ======================== #

func spawn_llave(pos: Vector2):
	var llave = llave_escena.instantiate()
	llave.position = pos + Vector2(0, -32)
	llave.portal = portal_path
	add_child(llave)

func spawn_enemigo(pos: Vector2):
	var enemigo = enemigo_escena.instantiate()
	enemigo.position = pos
	add_child(enemigo)
