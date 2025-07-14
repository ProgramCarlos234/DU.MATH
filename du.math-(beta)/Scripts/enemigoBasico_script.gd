extends CharacterBody2D

var jugador: CharacterBody2D
var velocidad: float
var EnemigoValue: int = -1  # Color del enemigo para validación
var movimiento_vertical: bool = false  # ← Añadido correctamente

@onready var Enemigo_label: Label = $Label

func _ready() -> void:
	Enemigo_label.text = str(EnemigoValue)

func _physics_process(delta):
	if movimiento_vertical:
		position.y += velocidad * delta
	else:
		if jugador:
			var direccion = (jugador.global_position - global_position).normalized()
			var movimiento = direccion * velocidad * delta
			var colision = move_and_collide(movimiento)

			if colision and colision.get_collider() == jugador:
				if jugador.has_method("recibir_dano"):
					jugador.recibir_dano()
				morir()

func morir():
	call_deferred("_morir_seguro")

func _morir_seguro():
	if is_inside_tree():
		var game = get_tree().get_first_node_in_group("game")
		if game and game.has_method("notificar_muerte"):
			game.notificar_muerte(self)
	queue_free()
