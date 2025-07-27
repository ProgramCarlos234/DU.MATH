extends CharacterBody2D

@export var speed: float = 50.0
@export var patrol_speed: float = 30.0
@export var detection_range: float = 120.0
@export var vision_range: float = 150.0
@export var iqDelJugador = 10

var jugador: Node2D
var estado := "patrullando"

# Puntos de patrulla - ajusta según tu mapa
@export var puntos_patrulla: Array[Vector2] = [
	Vector2(200, 200), 
	Vector2(400, 200), 
	Vector2(400, 400), 
	Vector2(200, 400)
]
var punto_actual := 0
var esperando := false
var tiempo_espera := 0.0
@export var tiempo_pausa: float = 2.0

func _ready():
	# Busca al jugador
	jugador = get_node("../Jugador")
	
	# Conecta la señal del Area2D
	$Area2D.body_entered.connect(_on_body_entered)
	
	# Si no hay puntos definidos, usa la posición actual
	if puntos_patrulla.is_empty():
		puntos_patrulla = [global_position]

func _physics_process(delta):
	if jugador and is_instance_valid(jugador):
		if puede_ver_jugador():
			estado = "siguiendo"
			seguir_jugador()
		else:
			estado = "patrullando"
			patrullar(delta)
	else:
		estado = "patrullando"
		patrullar(delta)
	
	# Movimiento más suave para RPG top-down
	move_and_slide()

func puede_ver_jugador() -> bool:
	if not jugador or not is_instance_valid(jugador):
		return false
	
	var distancia = global_position.distance_to(jugador.global_position)
	
	# Solo verifica distancia - más simple para RPG
	if distancia <= detection_range:
		return true
	
	return false

func seguir_jugador():
	if jugador and is_instance_valid(jugador):
		var direccion = (jugador.global_position - global_position).normalized()
		velocity = direccion * speed
		
		# NO usar look_at para top-down RPG, causa rotación extraña
		actualizar_animacion(direccion)

func patrullar(delta):
	if puntos_patrulla.is_empty():
		velocity = Vector2.ZERO
		return
	
	# Estado de espera
	if esperando:
		velocity = Vector2.ZERO
		tiempo_espera -= delta
		if tiempo_espera <= 0:
			esperando = false
			punto_actual = (punto_actual + 1) % puntos_patrulla.size()
		return
	
	var objetivo = puntos_patrulla[punto_actual]
	var distancia_al_objetivo = global_position.distance_to(objetivo)
	
	# Llegó al punto
	if distancia_al_objetivo < 20.0:
		esperando = true
		tiempo_espera = tiempo_pausa
		velocity = Vector2.ZERO
		return
	
	# Se mueve hacia el objetivo
	var direccion = (objetivo - global_position).normalized()
	velocity = direccion * patrol_speed
	
	# Actualiza animación según dirección
	actualizar_animacion(direccion)

func actualizar_animacion(direccion: Vector2):
	# Determina la dirección principal para la animación
	var sprite = $AnimatedSprite2D
	
	if abs(direccion.x) > abs(direccion.y):
		# Movimiento horizontal
		if direccion.x > 0:
			sprite.play("walk_right")
		else:
			sprite.play("walk_left")
	else:
		# Movimiento vertical
		if direccion.y > 0:
			sprite.play("walk_down")
		else:
			sprite.play("walk_up")

func _on_body_entered(body):
	if body.name == "Jugador":
		atrapar_jugador()

func atrapar_jugador():
	print("¡EvilBrain ha capturado al jugador!")
	iqDelJugador -=1
	print(iqDelJugador)
	if jugador:
		queue_free()
		# Reinicia al jugador en posición segura
		#jugador.global_position = Vector2(100, 100)  # Ajusta según tu spawn
		
		# Opcional: Efecto visual/sonoro de captura
		# $AudioStreamPlayer2D.play()
		
		# Opcional: Pausa momentánea
		# get_tree().create_timer(0.5).timeout.connect(func(): pass)

# SIN función _draw() - esto eliminará los círculos/radares
