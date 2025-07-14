extends CharacterBody2D

# Velocidad del personaje
@export var speed := 150.0

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO

	input_vector.x = Input.get_action_strength("Derecha") - Input.get_action_strength("Izquierda")
	input_vector.y = Input.get_action_strength("Abajo") - Input.get_action_strength("Arriba")

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()
