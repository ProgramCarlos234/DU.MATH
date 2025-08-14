extends CanvasLayer

signal pantalla_cerrada

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # Esto permite que funcione con el juego pausado

func _process(_delta):
	if Input.is_action_just_pressed("Interactuar"):
		emit_signal("pantalla_cerrada")
		queue_free()
