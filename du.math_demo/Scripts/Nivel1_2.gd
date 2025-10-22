extends Node2D

@export var enemigo_escena: PackedScene
@export var llave_escena: PackedScene
@export var posicion_llave: NodePath
@export var pantalla_inicio_escena: PackedScene  # Escena de CanvasLayer

@onready var label: Label = $Camera2D/Label
@onready var nodo_obstaculos = $NodoObstaculos
@onready var nodo_llave = get_node(posicion_llave)
@onready var camera_nivel: Camera2D = $Camera2D  # Ajusta la ruta si es distinta

var numero_objetivo: int
var Divisores: Array = [15, 27, 32, 45, 64]

var cajas_correctas_rotas := 0
const TOTAL_CORRECTAS := 14
var caja_a_grupo: Dictionary = {}
var caja_correcta_por_grupo: Dictionary = {}

func _ready():
	mostrar_pantalla_inicio()

# ========================
# Mostrar pantalla de inicio y pausar juego
# ========================
func mostrar_pantalla_inicio():
	if pantalla_inicio_escena:
		var pantalla = pantalla_inicio_escena.instantiate()
		add_child(pantalla)
		camera_nivel.visible = false
		pantalla.connect("pantalla_cerrada", Callable(self, "_on_pantalla_cerrada"))
		get_tree().paused = true
		$Camera2D/Control.visible = false

func _on_pantalla_cerrada():
	camera_nivel.visible = true
	get_tree().paused = false
	iniciar_juego()
	$Camera2D/Control.visible = true

# ========================
# Lógica original movida aquí
# ========================
func iniciar_juego():
	randomize()
	numero_objetivo = Divisores[randi_range(0, Divisores.size() - 1)]
	label.text = str(numero_objetivo)

	configurar_obstaculos()
	conectar_cajas()
	GameManager.iniciar_movimiento_paredes()

func configurar_obstaculos():
	for obstaculo in nodo_obstaculos.get_children():
		var cajas = obstaculo.get_children()
		var correcta_idx = randi() % cajas.size()

		var divisores_validos: Array = []
		for i in range(2, numero_objetivo):
			if numero_objetivo % i == 0:
				divisores_validos.append(i)

		if divisores_validos.is_empty():
			divisores_validos.append(numero_objetivo)

		var divisor_correcto = divisores_validos[randi() % divisores_validos.size()]
		
		for i in cajas.size():
			var caja = cajas[i]
			if i == correcta_idx:
				caja.numero = divisor_correcto
				caja_correcta_por_grupo[obstaculo] = caja
			else:
				var numero_incorrecto = 0
				while true:
					numero_incorrecto = randi_range(2, numero_objetivo + 10)
					if numero_objetivo % numero_incorrecto != 0 and numero_incorrecto != divisor_correcto:
						break
				caja.numero = numero_incorrecto

			caja.set_label(caja.numero)
			caja_a_grupo[caja] = obstaculo

func conectar_cajas():
	for obstaculo in nodo_obstaculos.get_children():
		for caja in obstaculo.get_children():
			caja.connect("caja_rota", Callable(self, "_on_caja_rota"))

func _on_caja_rota(numero: int, posicion: Vector2):
	var caja_que_exploto = get_caja_desde_posicion(posicion)
	if caja_que_exploto == null:
		return

	var grupo = caja_a_grupo.get(caja_que_exploto)
	if grupo == null:
		return

	var caja_correcta = caja_correcta_por_grupo.get(grupo)

	if caja_que_exploto == caja_correcta:
		cajas_correctas_rotas += 1
		grupo.queue_free()
		if cajas_correctas_rotas == TOTAL_CORRECTAS:
			instanciar_llave()
	else:
		for caja in grupo.get_children():
			if caja != caja_correcta:
				instanciar_enemigo(caja.global_position)
		grupo.queue_free()

func get_caja_desde_posicion(pos: Vector2) -> Node:
	for grupo in nodo_obstaculos.get_children():
		for caja in grupo.get_children():
			if caja.global_position == pos:
				return caja
	return null

func instanciar_llave():
	var llave = llave_escena.instantiate()
	nodo_llave.add_child(llave)

func instanciar_enemigo(posicion: Vector2):
	var enemigo = enemigo_escena.instantiate()
	get_tree().current_scene.add_child(enemigo)
	enemigo.global_position = posicion
