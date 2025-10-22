extends CharacterBody2D

signal attack_finished

@onready var movimiento_animacion: AnimatedSprite2D = $Movimiento_Animacion
@onready var ataque_animacion: AnimatedSprite2D = $Ataque_Animacion
@onready var attack_area: Area2D = $AreaAtaque

var velocidad: int = 100
var is_attack: bool = false
var is_emote: bool = false
var vida: int

func _ready():
	attack_area.monitoring = false

	if ataque_animacion:
		ataque_animacion.animation_finished.connect(_on_ataque_animacion_animation_finished)

	if movimiento_animacion:
		movimiento_animacion.animation_finished.connect(_on_movimiento_animacion_animation_finished)

	attack_area.body_entered.connect(_on_area_attack_body_entered)

func _process(_delta):
	vida = GameManager.VidaJugador

	if Input.is_action_just_pressed("Ataque") and not is_attack and not is_emote:
		attack()
		
	if Input.is_action_just_pressed("Emote") and not is_attack and not is_emote:
		play_emote()

func _physics_process(_delta):
	var direccion := Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")

	if is_attack or is_emote:
		velocity = Vector2.ZERO
	else:
		velocity = direccion * velocidad

	move_and_slide()

	# Cambiar visibilidad de animaciones
	if movimiento_animacion:
		movimiento_animacion.visible = not is_attack
	if ataque_animacion:
		ataque_animacion.visible = is_attack

	# Animaciones de movimiento (solo si no hay emote)
	if not is_emote and movimiento_animacion and movimiento_animacion.sprite_frames:
		if direccion.length() > 0 and movimiento_animacion.sprite_frames.has_animation("Movement"):
			movimiento_animacion.play("Movement")
		elif movimiento_animacion.sprite_frames.has_animation("Idle"):
			movimiento_animacion.play("Idle")

	# Voltear sprites y ajustar área de ataque
	if direccion.x != 0:
		var mirando_derecha = direccion.x > 0

		if movimiento_animacion:
			movimiento_animacion.flip_h = mirando_derecha
		if ataque_animacion:
			ataque_animacion.flip_h = mirando_derecha

		var offset = abs(attack_area.position.x)
		attack_area.position.x = offset if mirando_derecha else -offset

func attack():
	is_attack = true
	attack_area.monitoring = true

	if ataque_animacion and ataque_animacion.sprite_frames and ataque_animacion.sprite_frames.has_animation("attack"):
		ataque_animacion.play("attack")

# 🔹 --- SOLO SE MODIFICÓ ESTA FUNCIÓN Y SU CALLBACK ---
func play_emote():
	is_emote = true

	# Detiene cualquier animación activa
	if movimiento_animacion.is_playing():
		movimiento_animacion.stop()

	# Reproduce el emote si existe
	if movimiento_animacion.sprite_frames.has_animation("Emote"):
		movimiento_animacion.play("Emote")

func _on_movimiento_animacion_animation_finished():
	# Cuando termina el emote, vuelve a permitir animaciones normales
	if movimiento_animacion.animation == "Emote":
		is_emote = false
# 🔹 --------------------------------------------------

func _on_ataque_animacion_animation_finished():
	is_attack = false
	attack_area.monitoring = false
	attack_finished.emit()

func _on_area_attack_body_entered(body):
	if is_attack and body.is_in_group("Enemigos"):
		body.queue_free()
