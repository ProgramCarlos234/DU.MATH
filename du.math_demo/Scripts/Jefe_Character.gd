extends CharacterBody2D

@export var vida_max: int = 100
@export var spawn_interval_fase1: float = 10.0  # 40 seg
@export var spawn_interval_fase2: float = 30.0  # 1 min
@export var enemigos_por_fase1: int = 2
@export var enemigos_por_fase2: int = 4
@export var vida_fase2: int = 50
@export var vida_fase3: int = 20

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_timer: Timer = $WaveTimer

var spawn_points: Array = []
var question_points: Array = []

var vida_actual: int
var fase: int = 1
var jugador_activo: bool = false

func _ready():
	# Buscar nodos de spawn y preguntas de forma RELATIVA
	var spawns = get_parent().get_node_or_null("SpawnPoints")
	if spawns:
		spawn_points = spawns.get_children()
	else:
		print("⚠ No se encontraron puntos de spawn.")

	var preguntas = get_parent().get_node_or_null("QuestionPoints")
	if preguntas:
		question_points = preguntas.get_children()

	vida_actual = vida_max

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	wave_timer.timeout.connect(_on_wave_timer_timeout)

	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("Walk"):
		sprite.play("Walk")
	else:
		print("⚠ El sprite del jefe no tiene animación 'Walk' o no existe.")

	hide()

func iniciar():
	jugador_activo = true
	show()
	print("✅ Jefe activado en posición:", global_position)

	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("Walk"):
		sprite.play("Walk")

	iniciar_fase1()

func iniciar_fase1():
	fase = 1
	print("📌 Iniciando Fase 1: 2 enemigos cada 40 seg")
	spawn_timer.wait_time = spawn_interval_fase1
	spawn_timer.start()

func iniciar_fase2():
	fase = 2
	print("📌 Iniciando Fase 2: 4 enemigos cada 60 seg")
	spawn_timer.stop()
	spawn_timer.wait_time = spawn_interval_fase2
	spawn_timer.start()

func iniciar_fase3():
	fase = 3
	print("📌 Iniciando Fase 3: enemigos + ondas de ataque")
	spawn_timer.stop()
	spawn_timer.wait_time = spawn_interval_fase2  # o el tiempo que quieras
	spawn_timer.start()
	wave_timer.start()

func _on_spawn_timer_timeout():
	if spawn_points.is_empty():
		print("⚠ No hay puntos de spawn configurados.")
		return

	var cantidad = enemigos_por_fase1 if fase == 1 else enemigos_por_fase2
	print("⚔ Generando", cantidad, "enemigos (Fase", fase, ")")
	for i in range(cantidad):
		var punto = spawn_points.pick_random()
		var enemigo = preload("res://Scenas/ScenasJefe/Enemigos.tscn").instantiate()
		get_tree().current_scene.add_child(enemigo)
		enemigo.global_position = punto.global_position
	
func _on_wave_timer_timeout():
	print("🌊 Lanzando onda de ataque")

func recibir_danio(cantidad):
	if not jugador_activo:
		return

	vida_actual -= cantidad
	print("Vida del jefe:", vida_actual)

	if vida_actual <= vida_fase3 and fase < 3:
		iniciar_fase3()
	elif vida_actual <= vida_fase2 and fase < 2:
		iniciar_fase2()

	if vida_actual <= 0:
		derrotado()

func derrotado():
	print("🏆 ¡Jefe derrotado!")
	spawn_timer.stop()
	wave_timer.stop()
	queue_free()

func mostrar_pregunta():
	if question_points.is_empty():
		print("⚠ No hay puntos de pregunta configurados.")
		return

	var punto = question_points.pick_random()
	var pregunta = preload("res://Scenas/ScenasJefe/Preguntas.tscn").instantiate()
	get_tree().current_scene.add_child(pregunta)
	pregunta.global_position = punto.global_position
	if "boss" in pregunta:
		pregunta.boss = self
