extends Area2D

@export var daño: int = 10
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	connect("body_entered", Callable(self, "_on_area_entered"))
	if sprite and sprite.sprite_frames.has_animation("muro"):
		sprite.play("muro")

func _on_area_entered(body):
	if body.is_in_group("Jugador") and body.has_method("recibir_danio"):
		body.recibir_danio(daño)
