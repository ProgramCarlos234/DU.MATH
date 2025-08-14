extends Node2D

# Variables públicas de límites
@export var Limite_movimiento_muro_arriba: Marker2D
@export var Limite_movimiento_muro_abajo: Marker2D

# Variables privadas
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D2
@onready var muro_entrada: Sprite2D = $MuroEntrada
@onready var muro_entrada_2: Sprite2D = $MuroEntrada2

# Control de velocidad y estado
@export var velocidad_Movimiento_puerta: float = 100.0
var movimiento_abrir := false
var movimiento_cerrar := false

# Posiciones originales
var pos_original_muro_1: Vector2
var pos_original_muro_2: Vector2

func _ready() -> void:
	collision_shape_2d.disabled = false
	# Guardar posiciones iniciales
	pos_original_muro_1 = muro_entrada.position
	pos_original_muro_2 = muro_entrada_2.position

func _process(delta: float) -> void:
	if movimiento_abrir:
		# Movimiento hacia arriba (abrir)
		mover_muro(muro_entrada, Limite_movimiento_muro_arriba.position, delta)
		mover_muro(muro_entrada_2, Limite_movimiento_muro_abajo.position, delta)
		
		# Si ya están en posición, detiene el movimiento
		if muro_entrada.position.distance_to(Limite_movimiento_muro_arriba.position) < 1.0 \
		and muro_entrada_2.position.distance_to(Limite_movimiento_muro_abajo.position) < 1.0:
			movimiento_abrir = false
	
	elif movimiento_cerrar:
		# Movimiento de vuelta a la posición original
		mover_muro(muro_entrada, pos_original_muro_1, delta)
		mover_muro(muro_entrada_2, pos_original_muro_2, delta)
		
		if muro_entrada.position.distance_to(pos_original_muro_1) < 1.0 \
		and muro_entrada_2.position.distance_to(pos_original_muro_2) < 1.0:
			movimiento_cerrar = false

func mover_muro(muro: Sprite2D, destino: Vector2, delta: float) -> void:
	var direccion = (destino - muro.position).normalized()
	muro.position += direccion * velocidad_Movimiento_puerta * delta

func _on_izquierda_movimiento_abrir_puerta(Movimiento_Activado: bool) -> void:
	if Movimiento_Activado:
		collision_shape_2d.disabled = true
		movimiento_abrir = true
		movimiento_cerrar = false

func _on_izquierda_movimiento_cerrar_puerta(Movimiento_Activado: bool) -> void:
	if Movimiento_Activado:
		collision_shape_2d.disabled = false
		movimiento_cerrar = true
		movimiento_abrir = false
