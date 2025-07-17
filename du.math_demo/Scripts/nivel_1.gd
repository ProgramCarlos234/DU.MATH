extends Node2D

@export var enemigo_escena: PackedScene
@export var llave_escena: PackedScene
@export var posicion_llave: NodePath

@onready var label: Label = $Camera2D/Label
@onready var nodo_obstaculos = $NodoObstaculos
@onready var nodo_llave = get_node(posicion_llave)

var numero_objetivo: int
var cajas_correctas_rotas := 0

const TOTAL_CORRECTAS := 14

var caja_a_grupo: Dictionary = {}

func _ready():
	randomize()
	numero_objetivo = randi_range(2, 9)
	label.text = str(numero_objetivo)

	configurar_obstaculos()
	conectar_cajas()

func configurar_obstaculos():
	for obstaculo in nodo_obstaculos.get_children():
		var cajas = obstaculo.get_children()
		var correcta_idx = randi() % cajas.size()

		for i in cajas.size():
			var caja = cajas[i]
			if i == correcta_idx:
				caja.numero = numero_objetivo * randi_range(1, 5)
			else:
				var incorrecto = numero_objetivo * randi_range(1, 5) + 1
				if incorrecto % numero_objetivo == 0:
					incorrecto += 1
				caja.numero = incorrecto

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

	if numero % numero_objetivo == 0:
		# Caja correcta: eliminar grupo, sin enemigos
		cajas_correctas_rotas += 1
		grupo.queue_free()
		if cajas_correctas_rotas == TOTAL_CORRECTAS:
			instanciar_llave()
	else:
		# Caja incorrecta: enemigo en todas las incorrectas, incluida la rota
		for caja in grupo.get_children():
			if caja.numero % numero_objetivo != 0:
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
