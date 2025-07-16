# Extiende (hereda de) la clase CharacterBody2D de Godot para crear un personaje 2D con física
extends CharacterBody2D

# Obtiene una referencia al nodo AnimatedSprite2D (para animaciones) cuando el nodo está listo
@onready var sprite = $AnimatedSprite2D #sprites plataformas

# Variables exportadas (editables en el Inspector de Godot)
@export var SPEED = 150.0          # Velocidad horizontal del personaje
@export var JUMP_VELOCITY = -350.0  # Fuerza del salto (negativo porque el eje Y crece hacia abajo)

# Variable que almacena el valor del índice de la escena que se debe cargar
var valor: int

# Función _process: Se ejecuta cada frame (no se usa en este caso)
func _process(delta: float) -> void:
	# Si está dentro del área y el jugador presiona la tecla de interacción
	if GameManager.DentroArea and Input.is_action_just_pressed("Interactuar"):
		# Llama al GameManager para abrir la escena correspondiente según el valor actual
		GameManager._AbrirEscenas(valor)

# Función _physics_process: Se ejecuta en cada frame de física (tiempo fijo)
func _physics_process(delta: float) -> void:
	# Aplica gravedad si el personaje no está en el suelo
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Manejo del salto: solo salta si está en el suelo y se presiona la acción "Saltar"
	if Input.is_action_just_pressed("Saltar") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Obtiene la dirección horizontal de entrada (teclado/joystick)
	# - Retorna -1 (Izquierda), 1 (Derecha) o 0 (ninguna)
	var direction := Input.get_axis("Izquierda", "Derecha")
	
	# Mueve al personaje si hay dirección, o frena progresivamente
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Voltea el sprite según la dirección del movimiento
	if velocity.x > 0:
		sprite.scale.x = -1  # Derecha (asumiendo que -1 es la orientación correcta)
	elif velocity.x < 0:
		sprite.scale.x = 1   # Izquierda
	
	# Aplica el movimiento usando el método integrado de CharacterBody2D
	move_and_slide()
