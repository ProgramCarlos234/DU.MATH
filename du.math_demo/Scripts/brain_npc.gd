extends CharacterBody2D
signal atrapado

@export var speed: float = 60.0
var direction := Vector2.ZERO
var random_move_time := 1.5
var move_timer := 0.0

func _ready():
	randomize()
	pick_random_direction()
	$Area2D.body_entered.connect(_on_body_entered)

func _process(delta):
	move_timer -= delta
	if move_timer <= 0:
		pick_random_direction()
		move_timer = random_move_time
	velocity = direction * speed
	move_and_slide()

func pick_random_direction():
	var angle = randf_range(0, PI * 2)
	direction = Vector2(cos(angle), sin(angle)).normalized()

func _on_body_entered(body):
	if body.name == "Jugador":  # Cambiado para detectar por nombre
		emit_signal("atrapado")
		
		queue_free()
