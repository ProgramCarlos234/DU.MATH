# Hereda de CharacterBody2D para crear un personaje con física 2D
extends CharacterBody2D

# Obtiene referencia al nodo AnimatedSprite2D (asegúrate de que se llame 'Sprite' en la escena)
@onready var sprite = $AnimatedSprite2D #Asegúrate que el nodo hijo se llama 'Sprite'
# Obtiene referencia al propio nodo del jugador (no es necesario normalmente, ya que 'self' sería equivalente)
@onready var Jugador = $"." 

# Variable para detectar si el jugador está en un área interactuable
var DentroArea = false
# Velocidad de movimiento del personaje
var velocidad: int = 100

# Función que se ejecuta cada frame
func _process(delta: float) -> void:
	# Si está dentro del área y presiona el botón de interactuar, cambia de escena
	if DentroArea == true and Input.is_action_just_pressed("Interactuar"):
		get_tree().change_scene_to_file("res://Scenas/ScenasEntorno/EntornoPlataformas.tscn")
	pass

# Función de física que se ejecuta en intervalos fijos
func _physics_process(delta: float) -> void:
	# Obtiene dirección de entrada en 4 ejes (teclas/joystick)
	var Direccion = Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")
	# Aplica velocidad al vector de movimiento
	velocity = Direccion * velocidad
	# Mueve el personaje usando física
	move_and_slide()
	# Voltea el sprite según la dirección horizontal
	if Direccion.x > 0:
		sprite.scale.x = -1  # Derecha (asumiendo escala negativa)
	elif Direccion.x < 0:
		sprite.scale.x = 1   # Izquierda
	pass
	
# Señal que se ejecuta cuando un cuerpo entra al Area2D
func _on_area_2d_body_entered(body: Node2D) -> void:
	DentroArea = true  # Marca que el jugador está en el área
	pass # Replace with function body.

# Señal que se ejecuta cuando un cuerpo sale del Area2D
func _on_area_2d_body_exited(body: Node2D) -> void:
	DentroArea = false  # Marca que el jugador salió del área
	pass # Replace with function body.
