extends Camera2D

@export var jugador_path: NodePath = "Jugador" # Cambia si tu nodo se llama diferente

var jugador: Node2D

func _ready():
	make_current() 
	jugador = get_node(jugador_path)
	# Posiciona la cámara en el jugador al iniciar
	if jugador:
		global_position = jugador.global_position

func _process(delta):
	if jugador:
		# Movimiento suave siguiendo al jugador
		global_position = global_position.lerp(jugador.global_position, 0.15)
