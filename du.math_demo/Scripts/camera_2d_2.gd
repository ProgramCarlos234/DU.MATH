extends Camera2D

@onready var jugador: Node2D = get_node_or_null("../Jugador")
@export var suavizado: float = 5.0

func _ready() -> void:
	make_current()

func _process(delta: float) -> void:
	if jugador:
		global_position = global_position.lerp(jugador.global_position, delta * suavizado)
