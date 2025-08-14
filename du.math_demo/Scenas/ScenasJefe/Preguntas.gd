extends Node2D

var boss_ref = null
var jugador_dentro = false
var pregunta_activa = false

@onready var sprite: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var timer_pregunta = Timer.new()

func _ready():
	# Asegurar grupo "Jugador"
	var jugador = get_tree().get_first_node_in_group("Jugador")
	if not jugador:
		var posible_jugador = get_tree().root.find_child("Jugador", true, false)
		if posible_jugador:
			posible_jugador.add_to_group("Jugador")
			print("✅ Jugador agregado al grupo 'Jugador'.")

	# Animación inicial
	if sprite and sprite.sprite_frames.has_animation("Interrogacion"):
		sprite.play("Interrogacion")

	# Señales de entrada y salida del área
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

	# Configurar temporizador
	timer_pregunta.one_shot = true
	timer_pregunta.connect("timeout", Callable(self, "abrir_pregunta"))
	add_child(timer_pregunta)

func set_boss(boss):
	boss_ref = boss
	# Inicia el conteo para la primera pregunta (por ejemplo, 15 segundos)
	timer_pregunta.start(15)

func _on_body_entered(body):
	if body.is_in_group("Jugador"):
		jugador_dentro = true

func _on_body_exited(body):
	if body.is_in_group("Jugador"):
		jugador_dentro = false

# Solo se usa si quieres modo manual
func _input(event):
	if jugador_dentro and not pregunta_activa and event.is_action_pressed("Interactuar"):
		abrir_pregunta()

func abrir_pregunta():
	if pregunta_activa:
		return

	print("📜 Mostrando escena 'Preguntas_Jefe'.")
	pregunta_activa = true

	var preguntas_jefe = load("res://Scenas/ScenasEntorno/preguntas_jefe.tscn").instantiate()
	preguntas_jefe.global_position = global_position
	preguntas_jefe.connect("pregunta_terminada", Callable(self, "_on_pregunta_terminada"))
	get_tree().current_scene.add_child(preguntas_jefe)

func _on_pregunta_terminada(correcta):
	if boss_ref and boss_ref.has_method("pregunta_respondida"):
		boss_ref.pregunta_respondida()

	pregunta_activa = false
	# Programar próxima pregunta automática (20 seg después)
	timer_pregunta.start(20)
