extends Node2D

@export var enemigo_escena: PackedScene
@export var llave_escena: PackedScene
@export var posicion_llave: NodePath

@onready var label: Label = $Camera2D/Label
@onready var nodo_llave = get_node(posicion_llave)

var numero_objetivo: int
var Divisores: Array = [15, 27, 32, 45, 64]

func _ready():
	randomize()
	numero_objetivo = Divisores[randi_range(0, Divisores.size() - 1)]
	label.text = str(numero_objetivo)

func instanciar_llave():
	var llave = llave_escena.instantiate()
	nodo_llave.add_child(llave)

func instanciar_enemigo(posicion: Vector2):
	var enemigo = enemigo_escena.instantiate()
	get_tree().current_scene.add_child(enemigo)
	enemigo.global_position = posicion
