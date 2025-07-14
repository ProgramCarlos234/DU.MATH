extends CharacterBody2D
@onready var raycast := $RayCast2D
@onready var sprite := $SpriteJugadorBasico
@onready var contador := $"../MarginContainer/Label"
# Nodos donde están los enemigos — usados como objetivos del raycast
@onready var NodosObjetivo := [
	$"../1",
	$"../4",
	$"../2",
	$"../5",
	$"../3"
]
# Nodos físicos a los que el jugador se mueve (izquierda, centro, derecha)
@onready var NodosMovimiento := [
	$"../6",  # Izquierda
	$"../7",  # Centro
	$"../8"   # Derecha
]
var vida: int = 10
var nodo_index_objetivo := 2  # Comienza apuntando al nodo central de NodosObjetivo
var nodo_index_movimiento := 1  # Comienza en el nodo central de NodosMovimiento
var Estado_Movement: bool = false

func _physics_process(delta):
	contador.text = str(vida)

	if Estado_Movement:
		# Movimiento físico entre los 3 nodos de movimiento
		if Input.is_action_just_pressed("Izquierda"):
			nodo_index_movimiento = max(0, nodo_index_movimiento - 1)
			sprite.flip_h = true
			global_position = NodosMovimiento[nodo_index_movimiento].global_position

		elif Input.is_action_just_pressed("Derecha"):
			nodo_index_movimiento = min(NodosMovimiento.size() - 1, nodo_index_movimiento + 1)
			sprite.flip_h = false
			global_position = NodosMovimiento[nodo_index_movimiento].global_position

		# Raycast siempre hacia arriba
		raycast.target_position = Vector2(0, -500)

	else:
		# Apuntar con el raycast a los nodos objetivo (sin moverse físicamente)
		if Input.is_action_just_pressed("Izquierda"):
			nodo_index_objetivo = max(0, nodo_index_objetivo - 1)
			sprite.flip_h = true

		elif Input.is_action_just_pressed("Derecha"):
			nodo_index_objetivo = min(NodosObjetivo.size() - 1, nodo_index_objetivo + 1)
			sprite.flip_h = false

		# Raycast apunta al nodo seleccionado (objetivo)
		raycast.target_position = to_local(NodosObjetivo[nodo_index_objetivo].global_position)

	# Disparo a enemigo si hay colisión y el color es correcto
	if raycast.is_colliding():
		var obj = raycast.get_collider()
		if obj is CharacterBody2D and obj.has_method("morir"):
			for i in range(5):
				if Input.is_action_just_pressed("Color_%d" % i):
					if obj.EnemigoValue == i:
						obj.morir()

func recibir_dano():
	vida -= 1
	if vida <= 0:
		get_tree().change_scene_to_file("res://Rodrigo/ESCENAS/Derrota.tscn")
