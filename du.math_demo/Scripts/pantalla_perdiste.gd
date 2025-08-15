extends Node2D

@onready var Button_Pantalla: MenuButton = $Op1

@export var Indicador_mapa:int

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Button_Pantalla.button_pressed:
		GameManager._AbrirEscenas(Indicador_mapa)
		GameManager.VidaJugador = 10
		GameManager.LLaves_Conseguidas = 0
	pass
