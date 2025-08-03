extends CharacterBody2D
signal atrapado

@export var speed: float = 60.0

var jugador: Node2D
var direction := Vector2.ZERO

func _ready():
	# Buscar al jugador
	jugador = get_tree().get_first_node_in_group("player")
	if not jugador:
		jugador = get_node("../Jugador")  # Ajusta según tu estructura
	
	$Area2D.body_entered.connect(_on_body_entered)

func _process(delta):
	if jugador and is_instance_valid(jugador):
		# Siempre dirigirse hacia el jugador
		direction = (jugador.global_position - global_position).normalized()
	
	velocity = direction * speed
	move_and_slide()

func _on_body_entered(body):
	if body.name == "Jugador":
		emit_signal("atrapado")
		queue_free()
