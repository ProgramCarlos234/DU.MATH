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

# Para compatibilidad con HTML5 y mandos
var gamepad_connected: bool = false
var using_gamepad: bool = false
var last_input_time: float = 0.0
var input_cooldown: float = 0.2  # Prevenir cambios rápidos entre métodos de input

func _ready():
	attack_area.monitoring = false
	if ataque_animacion:
		ataque_animacion.animation_finished.connect(_on_ataque_animacion_animation_finished)
	attack_area.body_entered.connect(_on_area_attack_body_entered)
	
	# Detectar conexión de mando
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_check_for_gamepads()

func _process(delta):
	vida = GameManager.VidaJugador
	if vida <= 0:
		get_tree().change_scene_to_file("res://Scenas/ScenasEntorno/pantalla_perdiste.tscn") #Cambio de escenas cuando personaje muere
	
	# Actualizar temporizador
	last_input_time += delta
	
	# Detectar si se está usando mando o teclado (con cooldown)
	if last_input_time >= input_cooldown:
		_detect_input_method()
		last_input_time = 0.0

func _input(event):
	# Para HTML5: usar acciones en lugar de códigos de tecla específicos
	if event.is_action_pressed("Ataque") and can_move and not is_attack:
		print("DEBUG: Ataque detectado")
		attack()
		return

	if event.is_action_pressed("Interactuar"):
		print("DEBUG: Interacción detectada")
		if GameManager.DentroArea:
			if valor >= 0:
				# Pequeña pausa para asegurar que la entrada se procese correctamente
				await get_tree().create_timer(0.1).timeout
				GameManager._AbrirEscenas(valor)
			else:
				push_warning("⚠️ El portal no asignó un valor válido")
	
	# Detectar tipo de input basado en el evento actual
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		using_gamepad = true
	elif (event is InputEventKey or event is InputEventMouse):
		using_gamepad = false

func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Obtener dirección con soporte para mando (con deadzone)
	var direccion := Vector2.ZERO
	
	if using_gamepad:
		# Usar joystick con deadzone para evitar drift
		var joy_dir = Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")
		direccion = joy_dir if joy_dir.length() > 0.2 else Vector2.ZERO
	else:
		# Usar teclado
		direccion = Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")

	if is_attack:
		velocity = Vector2.ZERO
	else:
		velocity = direccion * velocidad
	move_and_slide()

	if movimiento_animacion:
		movimiento_animacion.visible = not is_attack
	if ataque_animacion:
		ataque_animacion.visible = is_attack

	if movimiento_animacion and movimiento_animacion.sprite_frames:
		if direccion.length() > 0 and movimiento_animacion.sprite_frames.has_animation("Movement"):
			movimiento_animacion.play("Movement")
		elif movimiento_animacion.sprite_frames.has_animation("Idle"):
			movimiento_animacion.play("Idle")

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

# Funciones nuevas para soporte de mando
func _on_joy_connection_changed(device_id, connected):
	gamepad_connected = connected
	if connected:
		print("Mando conectado: ", device_id)
	else:
		print("Mando desconectado: ", device_id)
		# No forzar using_gamepad = false aquí, dejar que _input lo detecte

func _check_for_gamepads():
	gamepad_connected = Input.get_connected_joypads().size() > 0
	print("Mandos conectados: ", Input.get_connected_joypads().size())

func _detect_input_method():
	# Solo cambiar si hay una diferencia clara
	if gamepad_connected:
		# Verificar si hay input de mando activo
		var joy_dir = Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")
		var has_gamepad_input = joy_dir.length() > 0.3
		
		# Verificar si hay input de teclado activo
		var has_keyboard_input = (
			Input.is_action_pressed("Izquierda") or
			Input.is_action_pressed("Derecha") or
			Input.is_action_pressed("Arriba") or
			Input.is_action_pressed("Abajo") or
			Input.is_action_pressed("Ataque") or
			Input.is_action_pressed("Interactuar")
		)
		
		# Cambiar solo si hay input claro de un método diferente
		if has_gamepad_input and not has_keyboard_input:
			using_gamepad = true
		elif has_keyboard_input and not has_gamepad_input:
			using_gamepad = false
