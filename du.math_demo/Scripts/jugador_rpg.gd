extends CharacterBody2D

signal attack_finished

@onready var movimiento_animacion: AnimatedSprite2D = $Movimiento_Animacion
@onready var ataque_animacion: AnimatedSprite2D = $Ataque_Animacion
@onready var attack_area: Area2D = $Ataque_Animacion/AreaAtaque

@export var velocidad: int = 100
var is_attack: bool = false
var vida: int
var valor: int = -1
var can_move: bool = true

func _ready():
	attack_area.monitoring = false
	if ataque_animacion:
		ataque_animacion.animation_finished.connect(_on_ataque_animacion_animation_finished)
	attack_area.body_entered.connect(_on_area_attack_body_entered)

func _process(_delta):
	# Vida jugador
	vida = GameManager.VidaJugador
	if vida <= 0:
		get_tree().change_scene_to_file("res://Scenas/ScenasEntorno/pantalla_perdiste.tscn")

	# 🔑 Interactuar con portal (tecla K)
	if Input.is_action_just_pressed("Interactuar") and GameManager.DentroArea:
		if valor >= 0:
			print("🔑 Abriendo portal a escena:", valor)
			GameManager._AbrirEscenas(valor)
		else:
			push_warning("⚠️ El portal no asignó un valor válido")

func _unhandled_input(event):
	# ⚔️ Ataque (tecla J, solo si puede moverse y no está atacando)
	if can_move and not is_attack and event.is_action_pressed("Ataque"):
		attack()

func _physics_process(_delta):
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# 🚶 Movimiento
	var direccion := Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")

	if is_attack:
		velocity = Vector2.ZERO
	else:
		velocity = direccion * velocidad

	move_and_slide()

	# Visibilidad de animaciones
	if movimiento_animacion:
		movimiento_animacion.visible = not is_attack
	if ataque_animacion:
		ataque_animacion.visible = is_attack

	# Animaciones
	if movimiento_animacion and movimiento_animacion.sprite_frames:
		if direccion.length() > 0 and movimiento_animacion.sprite_frames.has_animation("Movement"):
			movimiento_animacion.play("Movement")
		elif movimiento_animacion.sprite_frames.has_animation("Idle"):
			movimiento_animacion.play("Idle")

	# Flip + offset área de ataque
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

func _on_ataque_animacion_animation_finished():
	is_attack = false
	attack_area.monitoring = false
	attack_finished.emit()

func _on_area_attack_body_entered(body):
	if is_attack and body.is_in_group("Enemigos") and body is CharacterBody2D:
		body.queue_free()
