extends Node2D

var boss_ref = null

@onready var sprite: AnimatedSprite2D = $Area2D/AnimatedSprite2D

func _ready():
	# Reproducir la animación de interrogación al aparecer
	if sprite and sprite.sprite_frames.has_animation("Interrogacion"):
		sprite.play("Interrogacion")
	else:
		print("⚠ Pregunta sin animación 'Interrogacion'.")

	# Escuchar cuando el jugador entra en el área
	$Area2D.body_entered.connect(_on_body_entered)

func set_boss(boss):
	boss_ref = boss

func _on_body_entered(body):
	# Aquí puedes poner la lógica para abrir la pregunta o minijuego
	if body.is_in_group("Player"):
		print("💡 Jugador interactuó con la pregunta.")
		responder_pregunta()

func responder_pregunta():
	# Avisar al jefe que la pregunta fue respondida
	if boss_ref and boss_ref.has_method("pregunta_respondida"):
		boss_ref.pregunta_respondida()

	# Eliminar la pregunta de la escena
	queue_free()
