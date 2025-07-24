extends Node2D

@onready var Barra_vida: ProgressBar = $ProgressBar
@onready var Barra_IQ: ProgressBar = $ProgressBar2
@onready var jugador_Bien: Sprite2D = $JugadorBien1
@onready var jugador_Daño: Sprite2D = $JugadorBien2

var mostrando_daño = false
var contador: float = 0.0

func _process(delta: float) -> void:
	Barra_vida.value = GameManager.VidaJugador
	if GameManager.JugadorRecibeDaño and not mostrando_daño:
		mostrando_daño = true
		jugador_Bien.visible = false
		jugador_Daño.visible = true
		contador = 0.5  # reinicia el contador a 3 segundos
		GameManager.JugadorRecibeDaño = false  # resetea el flag para evitar que se repita

	if mostrando_daño:
		contador -= delta
		if contador <= 0.0:
			jugador_Bien.visible = true
			jugador_Daño.visible = false
			mostrando_daño = false
