# Hereda de CharacterBody2D para crear un personaje con física 2D
extends CharacterBody2D

# Referencia al nodo de animación del personaje
@onready var sprite = $AnimatedSprite2D

# Referencia al nodo del jugador (opcional, equivale a "self")
@onready var Jugador = $"." 

# Velocidad de movimiento del personaje
var velocidad: int = 100

# Variable que almacena el valor del índice de la escena que se debe cargar
var valor: int = 0
var iqDelJugador = 10

# Se ejecuta cada frame
func _process(delta: float) -> void:
	# Si está dentro del área y el jugador presiona la tecla de interacción
	if GameManager.DentroArea and Input.is_action_just_pressed("Interactuar"):
		# Llama al GameManager para abrir la escena correspondiente según el valor actual
		GameManager._AbrirEscenas(valor)

# Se ejecuta en intervalos fijos de tiempo, ideal para movimiento con física
func _physics_process(delta: float) -> void:
	# Obtiene el vector de dirección en función de las teclas presionadas
	var Direccion = Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")
	
	# Multiplica la dirección por la velocidad para obtener el movimiento
	velocity = Direccion * velocidad
	
	# Aplica movimiento usando física
	move_and_slide()
	
	# Voltea el sprite dependiendo de la dirección horizontal
	if Direccion.x > 0:
		sprite.scale.x = -1  # Hacia la derecha
	elif Direccion.x < 0:
		sprite.scale.x = 1   # Hacia la izquierda
		
		
		
func aumentar_puntaje():
	iqDelJugador +=1
	print("aumentar jug")
