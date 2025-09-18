extends Area2D

@export var duracion: float = 2.0
@export var danio: int = 1

func _ready():
	# Conectar la señal si no la conectaste desde el editor
	connect("body_entered", Callable(self, "_on_body_entered"))

	# El ataque desaparece después de "duracion"
	await get_tree().create_timer(duracion).timeout
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("Jugador"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(danio)
			print("🔥 AtaqueSuelo golpeó al jugador por ", danio, " de daño")
