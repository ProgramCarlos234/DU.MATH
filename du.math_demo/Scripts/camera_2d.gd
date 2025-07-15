extends Camera2D
	  
@onready var jugador: CharacterBody2D = $"../Jugador" #inicializamos la variable del jugador para obtener su posicion
	
var PosicionY: float
var vector_Limites
#Esta funcion se ejecuta constantemente por cada freime del juego
func _process(delta: float) -> void:
	PosicionY = jugador.position.y
	vector_Limites = Vector2(0,PosicionY)
	position = jugador.position #con esta linea de codigo la camara seguira constantemente al jugador
	if position.x <= 0:
		position = vector_Limites
	pass
