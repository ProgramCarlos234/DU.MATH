extends Node

# ======================= #
#       VARIABLES         #
# ======================= #

var DentroArea := false # variable usada para detectar que el jugador se encuentra dentro de un area 2D
var VidaJugador: int = 10 # variable usada para almacenar la vida del jugador
var IQJugador: int = 40# variable usada para almacenar la vida del jugador
var JugadorRecibeDaño = false
var paredes: Array = []
var indice_actual := 0
var llave_conseguida = false #variable usada para detectar que el jugador obtiene la llave

# ======================= #
#    ESCENAS DISPONIBLES  #
# ======================= #

const MAPA_JUEGO = preload("res://Scenas/ScenasEntorno/Mapa_juego.tscn")
const ENTORNO_RPG = preload("res://Scenas/ScenasEntorno/EntornoRPG.tscn")
const ENTORNO_PLATAFORMAS = preload("res://Scenas/ScenasEntorno/EntornoPlataformas.tscn")
const NIVEL_1_MOVER_CAJAS = preload("res://Scenas/ScenasEntorno/Nivel1_MoverCajas.tscn")
const MAPA_JUEGO_ISLAND = preload("res://Scenas/ScenasEntorno/Mapa_juego_Island.tscn")
const SUB_NIVELES = preload("res://Scenas/ScenasEntorno/sub_niveles.tscn")
const NIVEL_1_2_DIVISORES = preload("res://Scenas/ScenasEntorno/Nivel1_2Divisores.tscn")

var Scenas: Array = [
	MAPA_JUEGO,
	ENTORNO_RPG,
	ENTORNO_PLATAFORMAS,
	NIVEL_1_MOVER_CAJAS,
	MAPA_JUEGO_ISLAND,
	SUB_NIVELES,
	NIVEL_1_2_DIVISORES
]

# ======================= #
#        _READY           #
# ======================= #
func _ready() -> void:
	await get_tree().process_frame  # Esperar a que se cargue toda la escena
	
# ============================== #
#  GENERACIÓN DE NÚMERO OBJETIVO #
# ============================== #
func _AbrirEscenas(valor: int) ->void:
	if valor >= 0 and valor < Scenas.size():
		get_tree().change_scene_to_packed(Scenas[valor])
	pass

func _recibirDaño(Daño : int) -> void:
	VidaJugador -= Daño
	JugadorRecibeDaño = true
	pass

# ============================== #
#   MOVIMIENTO DE PAREDES PUAS   #
# ============================== #
func iniciar_movimiento_paredes():
	var contenedor = get_tree().current_scene.get_node("Paredes")
	paredes = contenedor.get_children()  # Cada uno es un ParedPuas
	indice_actual = 0

	if paredes.size() > 0:
		conectar_y_mover(paredes[0])

func conectar_y_mover(pared_puas):
	var pared_real = pared_puas.get_node("Pared")
	pared_real.connect("movimiento_terminado", Callable(self, "_on_pared_movida"))
	pared_real.iniciar_movimiento()

func _on_pared_movida():
	indice_actual += 1
	if indice_actual < paredes.size():
		conectar_y_mover(paredes[indice_actual])
