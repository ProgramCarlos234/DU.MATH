extends Area2D

@export var daño: int = 2
@export var duracion: float = 5.0  # ⏰ tiempo en segundos antes de desaparecer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	connect("body_entered", Callable(self, "_on_area_entered"))
	
	if sprite and sprite.sprite_frames.has_animation("muro"):
		sprite.play("muro")

	# 💥 Desaparecer automáticamente después de unos segundos
	await get_tree().create_timer(duracion).timeout
	queue_free()

func _on_area_entered(body):
	if body.is_in_group("Jugador") and body.has_method("recibir_danio"):
		body.recibir_danio(daño)
