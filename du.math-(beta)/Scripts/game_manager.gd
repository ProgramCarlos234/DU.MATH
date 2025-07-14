class_name GameManager
extends Node2D

const enemigo_scene = preload("res://PersonajesEscenas/Enemigo.tscn")
@export var jugador: CharacterBody2D

@onready var spawns_iniciales = [$"../1", $"../2", $"../3"]
@onready var spawns_fase2 = [$"../4", $"../5"]
@onready var spawns_Jefe = [$"../4",$"../2",$"../5"]
@onready var timer: Timer = $"../Timer"
@onready var Musica = $"../AudioStreamPlayer2D"

var enemigos_vivos = []
var fase_actual_es_inicial
var ciclos_completados: int = 0
var hordas_por_ciclo: int = 2
var hordas_hechas_en_ciclo: int = 0
var etapas: int = 2

func _ready():
	Musica.play()
	jugador = $"../Jugador"  # ← Asegura que esté correctamente asignado
	fase_actual_es_inicial = true
	add_to_group("game")
	spawn_fase_actual()

func _process(delta: float) -> void:
	if etapas <= 0:
		jugador.Estado_Movement = true

func spawn_fase_actual():
	var colores := []
	var spawns := []

	if etapas <= 0:
		# Etapa especial: jugador se mueve, enemigos con valores 0,2,4 bajan
		colores = [0, 2, 4]
		spawns = spawns_Jefe  # Usa los nodos "../1", "../2", "../3"
	else:
		if fase_actual_es_inicial:
			colores = [0, 2, 4]
			spawns = spawns_iniciales
		else:
			colores = [1, 3]
			spawns = spawns_fase2

	colores.shuffle()  # Opcional
	for i in range(spawns.size()):
		if i < colores.size():
			spawn_enemigo(spawns[i], colores[i])

func spawn_enemigo(spawner: Node2D, color_index: int):
	var enemigo = enemigo_scene.instantiate()
	enemigo.jugador = $"../Jugador"
	enemigo.global_position = spawner.global_position
	enemigo.velocidad = 50
	enemigo.EnemigoValue = color_index
	enemigo.movimiento_vertical = etapas <= 0  # Se mueve hacia abajo solo en etapa 3

	var sprite = enemigo.get_node("Sprite2D")
	var mat = sprite.material.duplicate() as ShaderMaterial
	sprite.material = mat
	mat.set_shader_parameter("color_index", color_index)

	var label = enemigo.get_node("Label")
	label.text = str(color_index)

	enemigo.add_to_group("enemigo")
	add_child(enemigo)
	enemigos_vivos.append(enemigo)

func notificar_muerte(enemigo):
	if enemigo in enemigos_vivos:
		enemigos_vivos.erase(enemigo)
	if enemigos_vivos.is_empty():
		hordas_hechas_en_ciclo += 1
		if hordas_hechas_en_ciclo < hordas_por_ciclo:
			fase_actual_es_inicial = !fase_actual_es_inicial
			spawn_fase_actual()
		else:
			ciclos_completados += 1
			hordas_hechas_en_ciclo = 0
			if ciclos_completados >= 2:
				ciclos_completados = 0
				etapas -= 1
				timer.start()
			else:
				fase_actual_es_inicial = true
				spawn_fase_actual()

func _on_timer_timeout() -> void:
	fase_actual_es_inicial = true
	hordas_hechas_en_ciclo = 0
	spawn_fase_actual()
