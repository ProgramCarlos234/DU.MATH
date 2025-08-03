extends CharacterBody2D

signal attack_finished

@onready var movimiento_animacion: AnimatedSprite2D = $Movimiento_Animacion
@onready var ataque_animacion: AnimatedSprite2D = $Ataque_Animacion
@onready var Jugador = $"."  # Referencia al nodo del jugador
@onready var tilemap = get_node("../TileMapLayer")

var iqDelJugador = 10
var is_attack = false
var velocidad: int = 100
var valor: int = 0
var vida: int

func _process(delta: float) -> void:
	vida = GameManager.VidaJugador
	
	if GameManager.DentroArea and Input.is_action_just_pressed("Interactuar"):
		GameManager._AbrirEscenas(valor)

	if Input.is_action_just_pressed("Ataque") and not is_attack:
		attack()

func _physics_process(delta: float) -> void:
	var direccion = Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")
	
	if is_attack:
		velocity = Vector2.ZERO
		movimiento_animacion.visible = false
		ataque_animacion.visible = true
	else:
		velocity = direccion * velocidad
		move_and_slide()
		
		movimiento_animacion.visible = true
		ataque_animacion.visible = false

		if direccion.x != 0:
			movimiento_animacion.scale.x = -1 if direccion.x > 0 else 1
			ataque_animacion.scale.x = -1 if direccion.x > 0 else 1
			$Ataque_Animacion/AreaAttack.scale.x = movimiento_animacion.scale.x
			movimiento_animacion.play("Movement")
			
		elif direccion.y != 0:
			movimiento_animacion.play("Movement")
			
		else:
			movimiento_animacion.play("Idle")

func aumentar_puntaje():
	iqDelJugador += 1

func attack():
	is_attack = true
	ataque_animacion.visible = true
	ataque_animacion.play("attack")

func _on_ataque_animacion_animation_finished() -> void:
	is_attack = false
	attack_finished.emit()
