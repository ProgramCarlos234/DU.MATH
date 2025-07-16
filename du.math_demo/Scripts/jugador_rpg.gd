extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@export var velocidad: int = 100

# Variables para interacción con portal
var puede_interactuar: bool = false
var portal_actual: Area2D = null

func _process(delta):
	# Sistema de interacción con portal
	if puede_interactuar and Input.is_action_just_pressed("Interactuar"):
		if portal_actual and portal_actual.has_method("cambiar_escena"):
			portal_actual.cambiar_escena()

func _physics_process(delta):
	var direccion = Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")
	velocity = direccion * velocidad
	move_and_slide()
	
	if direccion.x > 0:
		sprite.scale.x = -1
	elif direccion.x < 0:
		sprite.scale.x = 1

func _on_area_portal_entered(area):
	if area.is_in_group("portal"):
		puede_interactuar = true
		portal_actual = area
		GameManager.DentroArea = true

func _on_area_portal_exited(area):
	if area.is_in_group("portal"):
		puede_interactuar = false
		portal_actual = null
		GameManager.DentroArea = false
