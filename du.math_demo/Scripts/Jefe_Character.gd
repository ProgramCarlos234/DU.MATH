extends Node2D

var boss_ref = null
var jugador_dentro = false
var pregunta_activa = false
var pregunta_actual = {}

@onready var sprite: AnimatedSprite2D = $Area2D/AnimatedSprite2D

func _ready():
	set_process_input(true)

	# Asegurar que el jugador esté en el grupo
	var jugador = get_tree().get_first_node_in_group("Jugador")
	if not jugador:
		var posible_jugador = get_tree().root.find_child("Jugador", true, false)
		if posible_jugador:
			posible_jugador.add_to_group("Jugador")
			print("✅ Jugador agregado al grupo 'Jugador'.")

	if sprite and sprite.sprite_frames.has_animation("Interrogacion"):
		sprite.play("Interrogacion")

	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func set_boss(boss):
	boss_ref = boss

func set_pregunta(p):
	pregunta_actual = p
	_mostrar_pregunta()

func _on_body_entered(body):
	if body.is_in_group("Jugador"):
		jugador_dentro = true

func _on_body_exited(body):
	if body.is_in_group("Jugador"):
		jugador_dentro = false

func _input(event):
	if jugador_dentro and not pregunta_activa and event.is_action_pressed("Interactuar"):
		abrir_pregunta()

func abrir_pregunta():
	if pregunta_activa or pregunta_actual.size() == 0:
		return

	pregunta_activa = true

	var preguntas_jefe = load("res://Scenas/ScenasEntorno/preguntas_jefe.tscn").instantiate()
	preguntas_jefe.global_position = global_position
	preguntas_jefe.connect("pregunta_terminada", Callable(self, "_on_pregunta_terminada"))
	get_tree().current_scene.add_child(preguntas_jefe)

	if sprite:
		sprite.visible = false

func _mostrar_pregunta():
	if pregunta_actual.size() == 0:
		return
	# Aquí podrías actualizar el texto del intermedio si quieres mostrarlo

func _on_pregunta_terminada(correcta: bool):
	if boss_ref and boss_ref.has_method("pregunta_respondida"):
		boss_ref.pregunta_respondida(correcta)
	pregunta_activa = false
	if sprite:
		sprite.visible = true
	queue_free()
