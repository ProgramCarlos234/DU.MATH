extends Node2D

@onready var Barra_vida: ProgressBar = $ProgressBar
@onready var Barra_IQ: ProgressBar = $ProgressBar2
@onready var jugador_Bien: Sprite2D = $JugadorBien1
@onready var jugador_Daño: Sprite2D = $JugadorBien2
@onready var LabelIQ: Label = $Label3
@onready var CantidadLLaves: Label = $Label5

var mostrando_daño: bool = false
var contador: float = 0.0

func _process(delta: float) -> void:
	# Actualiza las barras con los valores del GameManager
	CantidadLLaves.text = str(GameManager.LLaves_Conseguidas)
	Barra_vida.value = GameManager.VidaJugador
	Barra_IQ.value = GameManager.IQJugador
	
	# Muestra el valor de IQ como texto
	LabelIQ.text = str(GameManager.IQJugador)

	# Si el jugador recibe daño y aún no se está mostrando el sprite de daño
	if GameManager.JugadorRecibeDaño and not mostrando_daño:
		mostrando_daño = true
		jugador_Bien.visible = false
		jugador_Daño.visible = true
		contador = 0.5  # duración del efecto de daño
		GameManager.JugadorRecibeDaño = false  # resetear flag

	# Si se está mostrando el sprite de daño, cuenta el tiempo y revierte el sprite
	if mostrando_daño:
		contador -= delta
		if contador <= 0.0:
			jugador_Bien.visible = true
			jugador_Daño.visible = false
			mostrando_daño = false
