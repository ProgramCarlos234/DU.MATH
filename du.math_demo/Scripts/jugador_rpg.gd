# Hereda de CharacterBody2D para crear un personaje con física 2D
extends CharacterBody2D

var velocidad: int = 100 # Velocidad de movimiento del personaje
var valor: int = 0  # Variable que almacena el valor del índice de la escena que se debe cargar
var vida: int

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D # Referencia al nodo de animación del personaje
@onready var sprite = $AnimatedSprite2D
@onready var Jugador = $"."  # Referencia al nodo del jugador (opcional, equivale a "self")
@onready var tilemap = get_node("../TileMaps")
# Velocidad de movimiento del personaje
# Variable que almacena el valor del índice de la escena que se debe cargar
var iqDelJugador = 10

# Se ejecuta cada frame
func _process(delta: float) -> void:
	vida = GameManager.VidaJugador
	if GameManager.DentroArea and Input.is_action_just_pressed("Interactuar"):
		GameManager._AbrirEscenas(valor)
	# Agregar condicional en esta parte cuando el jugador llegue a 0 de vida
	
# Se ejecuta en intervalos fijos de tiempo, ideal para movimiento con física
func _physics_process(delta: float) -> void:
	var Direccion = Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")
	velocity = Direccion * velocidad
	move_and_slide()
	if Direccion.x > 0:
		animated_sprite_2d.play("Movement")
		sprite.scale.x = -1  # Hacia la derecha
	elif Direccion.x < 0:
		animated_sprite_2d.play("Movement")
		sprite.scale.x = 1   # Hacia la izquierda
	elif Direccion.x == 0:
		animated_sprite_2d.play("Idle")
		
		
func aumentar_puntaje():
	iqDelJugador +=1
	print("aumentar jug")
