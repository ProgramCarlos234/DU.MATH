extends Area2D

@export var danio: int = 1
@export var tiempo_aviso: float = 1.0  # Duración de la animación de aviso
@export var tiempo_ataque: float = 1.5 # Duración del ataque real

@onready var sprite = $AnimatedSprite2D

func _ready():
	# ❌ Desactivar colisión durante el aviso
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	# Inicia con la animación de aviso
	if sprite.sprite_frames.has_animation("aviso"):
		sprite.play("aviso")
		print("⚠️ Mostrando aviso de ataque de suelo")
	
	# Esperar que acabe el aviso y luego lanzar el ataque real
	_iniciar_ataque()


func _iniciar_ataque() -> void:
	await get_tree().create_timer(tiempo_aviso).timeout

	# ✅ Cambiar a animación de ataque (ahora sí daña)
	if sprite.sprite_frames.has_animation("ataque"):
		sprite.play("ataque")
		print("🔥 Ataque del suelo activado")

	# ✅ Activar colisión (daño) solo durante el ataque
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)

	await get_tree().create_timer(tiempo_ataque).timeout

	# ❌ Desactivar colisión y eliminar después del ataque
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	queue_free()


func _on_body_entered(body):
	if body.is_in_group("Jugador") and body.has_method("recibir_danio"):
		body.recibir_danio(danio)
		print("💥 Jugador recibió", danio, "de daño por AtaqueSuelo")
