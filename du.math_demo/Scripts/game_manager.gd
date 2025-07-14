extends Node

# Definición de señales (en el GameManager)
signal interaction_available(changed: bool, area_name: String)  # Cuando el jugador entra/sale de un área
signal scene_change_requested(scene_path: String)  # Cuando se solicita un cambio de escena

#creacion de variables de control en el gamemanager
var DentroArea:bool = false

#cinicializacion de constantes para las escenas de los niveles
const MAPA_JUEGO = preload("res://Scenas/ScenasEntorno/Mapa_juego.tscn")
const ENTORNO_RPG = preload("res://Scenas/ScenasEntorno/EntornoRPG.tscn")
const ENTORNO_PLATAFORMAS = preload("res://Scenas/ScenasEntorno/EntornoPlataformas.tscn")

#Creacion de un array de scenas que permita el control de abrir o cerrar escenas
var Scenas: Array = [
	MAPA_JUEGO, #Escena RPG donde se presentaran los diferentes niveles del juego
	ENTORNO_RPG, #Primera Escena que se ve, en donde el jugador es transportado para hablar con la entidad
	ENTORNO_PLATAFORMAS #Escena de 2D plataformas, reservado para el nivel del puente
]

func  _AbrirEscenas(valor: int):
	if valor >= 0 and valor < Scenas.size():   #Se verifica que el valor que estamos igualando sea un valor real y manipulable
		get_tree().change_scene_to_packed(Scenas[valor]) # abre una escena en funcion del valor que se le entregue al array
	else:
		push_error("Índice de escena inválido: " + str(valor)) #en caso no se encuentra dara un mensaje en el debug
	pass
