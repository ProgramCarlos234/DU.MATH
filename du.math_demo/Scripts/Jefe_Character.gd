extends CharacterBody2D

@export var vida_max: int = 100
@export var spawn_interval_fase1: float = 10.0
@export var spawn_interval_fase2: float = 30.0
@export var enemigos_por_fase1: int = 2
@export var enemigos_por_fase2: int = 4
@export var vida_fase2: int = 50
@export var vida_fase3: int = 20

@export var primera_pregunta_delay: float = 15.0
@export var pregunta_interval: float = 20.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_timer: Timer = $WaveTimer
@onready var pregunta_timer: Timer = $PreguntaTimer

var spawn_points: Array = []
var question_points: Array = []

var vida_actual: int
var fase: int = 1
var jugador_activo: bool = false
var pregunta_activa: bool = false

# Lista de preguntas del jefe
var preguntas = [
	{"texto":"90 ÷ 15 =", "opciones":["5","6","7"], "correcta":"A"},
	{"texto":"3/4 de 20 =", "opciones":["10","15","12"], "correcta":"B"},
	{"texto":"25% de 80 =", "opciones":["15","20","25"], "correcta":"B"}
]
var preguntas_restantes: Array = []

func _ready():
	randomize()
	preguntas_restantes = preguntas.duplicate()

	# Guardar spawn points y puntos de preguntas
	var spawns = get_parent().get_node_or_null("SpawnPoints")
	if spawns:
		spawn_points = spawns.get_children()

	var preguntas_nodes = get_parent().get_node_or_null("QuestionPoints")
	if preguntas_nodes:
		question_points = preguntas_nodes.get_children()

	vida_actual = vida_max

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	pregunta_timer.timeout.connect(mostrar_pregunta)

	if sprite and sprite.sprite_frames.has_animation("Walk"):
		sprite.play("Walk")

	hide()

func iniciar():
	jugador_activo = true
	show()
	iniciar_fase1()

	# Primera pregunta
	pregunta_timer.wait_time = primera_pregunta_delay
	pregunta_timer.start()

func iniciar_fase1():
	fase = 1
	spawn_timer.wait_time = spawn_interval_fase1
	spawn_timer.start()

func iniciar_fase2():
	fase = 2
	spawn_timer.stop()
	spawn_timer.wait_time = spawn_interval_fase2
	spawn_timer.start()

func iniciar_fase3():
	fase = 3
	spawn_timer.stop()
	spawn_timer.wait_time = spawn_interval_fase2
	spawn_timer.start()
	wave_timer.start()

func _on_spawn_timer_timeout():
	if spawn_points.is_empty():
		return
	var cantidad = enemigos_por_fase1 if fase == 1 else enemigos_por_fase2
	for i in range(cantidad):
		var punto = spawn_points.pick_random()
		var enemigo = preload("res://Scenas/ScenasJefe/Enemigos.tscn").instantiate()
		get_tree().current_scene.add_child(enemigo)
		enemigo.global_position = punto.global_position

func _on_wave_timer_timeout():
	print("🌊 Lanzando onda de ataque")

func recibir_danio(cantidad: int):
	if not jugador_activo:
		return
	vida_actual -= cantidad
	if vida_actual <= vida_fase3 and fase < 3:
		iniciar_fase3()
	elif vida_actual <= vida_fase2 and fase < 2:
		iniciar_fase2()
	if vida_actual <= 0:
		derrotado()

func derrotado():
	print("🏆 ¡Jefe derrotado! 🚫")
	spawn_timer.stop()
	wave_timer.stop()
	pregunta_timer.stop()
	queue_free()

func mostrar_pregunta():
	if question_points.is_empty() or preguntas_restantes.is_empty():
		return

	var punto = question_points.pick_random()
	var intermedio = preload("res://Scenas/ScenasJefe/Preguntas.tscn").instantiate()
	intermedio.global_position = punto.global_position
	intermedio.set_boss(self)

	var idx = randi() % preguntas_restantes.size()
	var p = preguntas_restantes[idx]
	preguntas_restantes.remove_at(idx)
	intermedio.set_pregunta(p)

	get_tree().current_scene.add_child(intermedio)


func pregunta_respondida(correcta: bool):
	print("📩 Pregunta respondida. Correcta =", correcta)
	if correcta:
		recibir_danio(10)
	pregunta_activa = false
	pregunta_timer.wait_time = pregunta_interval
	pregunta_timer.start()
