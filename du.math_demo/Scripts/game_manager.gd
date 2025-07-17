extends Node
# ======================= #
#       VARIABLES         #
# ======================= #
var DentroArea := false
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
