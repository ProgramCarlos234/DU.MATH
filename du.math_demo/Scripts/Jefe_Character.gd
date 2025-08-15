extends CharacterBody2D

@export var vida_max: int = 100
@export var spawn_interval_fase1: float = 10.0
@export var spawn_interval_fase2: float = 10.0
@export var enemigos_por_fase1: int = 2
@export var enemigos_por_fase2: int = 4

@export var primera_pregunta_delay: float = 20.0
@export var pregunta_interval: float = 20.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_timer: Timer = $WaveTimer
@onready var pregunta_timer: Timer = $PreguntaTimer

var spawn_points: Array = []
var question_points: Array = []

var fase: int = 1
var jugador_activo: bool = false
var pregunta_activa: bool = false

# Lista de preguntas del jefe
var preguntas = [
	{"texto":"90 ÷ 15 =", "opciones":["5","6","7"], "correcta":"A"},
	{"texto":"3/4 de 20 =", "opciones":["10","15","12"], "correcta":"B"},
	{"texto":"25% de 80 =", "opciones":["15","20","25"], "correcta":"B"},
	{"texto":"7 × 8 =", "opciones":["54","56","58"], "correcta":"B"},
	{"texto":"12 + 15 =", "opciones":["27","28","26"], "correcta":"A"},
	{"texto":"45 − 17 =", "opciones":["28","29","30"], "correcta":"A"},
	{"texto":"50 ÷ 5 =", "opciones":["10","9","12"], "correcta":"A"},
	{"texto":"2/5 de 50 =", "opciones":["20","25","30"], "correcta":"A"},
	{"texto":"60% de 50 =", "opciones":["25","30","35"], "correcta":"B"},
	{"texto":"Triángulo con lados 3 y 4, \nhallar hipotenusa", "opciones":["5","6","7"], "correcta":"A"},
	{"texto":"Área de un rectángulo 5×8", "opciones":["40","45","50"], "correcta":"A"},
	{"texto":"Perímetro de un cuadrado de lado 7", "opciones":["28","24","21"], "correcta":"A"},
	{"texto":"15 × 4 =", "opciones":["60","55","65"], "correcta":"A"},
	{"texto":"100 − 37 =", "opciones":["63","67","73"], "correcta":"A"},
	{"texto":"3/8 de 32 =", "opciones":["12","11","10"], "correcta":"A"},
	{"texto":"Si un triángulo tiene \nlados 6 y 8, hipotenusa =", "opciones":["10","12","9"], "correcta":"A"},
	{"texto":"20% de 90 =", "opciones":["18","19","20"], "correcta":"A"},
	{"texto":"Suma de 25 + 47", "opciones":["72","71","73"], "correcta":"A"},
	{"texto":"Dividir 81 ÷ 9 =", "opciones":["8","9","10"], "correcta":"B"},
	{"texto":"Área de un triángulo\n base 6 altura 4", "opciones":["12","14","10"], "correcta":"A"}
]
var preguntas_restantes: Array = []

# Contador de preguntas correctas
var correctas_contador: int = 0

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
	print("🟢 Fase 1 iniciada")

func iniciar_fase2():
	fase = 2
	spawn_timer.stop()
	spawn_timer.wait_time = spawn_interval_fase2
	spawn_timer.start()
	print("🟡 Fase 2 iniciada (vida 2/3)")

func iniciar_fase3():
	fase = 3
	spawn_timer.stop()
	spawn_timer.wait_time = spawn_interval_fase2
	spawn_timer.start()
	wave_timer.start()
	print("🔴 Fase 3 iniciada (vida 1/3)")

func _on_spawn_timer_timeout():
	if spawn_points.size() == 0:
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
	# La vida ahora la manejamos con preguntas correctas, opcional dejarlo por si hay daño físico
	pass

func derrotado():
	print("🏆 ¡Jefe derrotado! 🚫")
	spawn_timer.stop()
	wave_timer.stop()
	pregunta_timer.stop()
	queue_free()

func mostrar_pregunta():
	if question_points.size() == 0 or preguntas_restantes.size() == 0:
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
	pregunta_activa = false

	if correcta:
		correctas_contador += 1
		print("✅ Preguntas correctas acumuladas: ", correctas_contador)

		# Cambiar fases según preguntas correctas
		if correctas_contador == 4:
			iniciar_fase2()
		elif correctas_contador == 8:
			iniciar_fase3()
		elif correctas_contador >= 12:
			derrotado()

	# Reiniciar timer para próxima pregunta
	pregunta_timer.wait_time = pregunta_interval
	pregunta_timer.start()
