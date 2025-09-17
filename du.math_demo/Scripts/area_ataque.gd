extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var mordida: AnimatedSprite2D = $".."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var inicio_frame: int = 4
var fin_frame: int = 9

func _ready() -> void:
	collision_shape_2d.disabled = true  # Desactivar al inicio
	mordida.connect("frame_changed", Callable(self, "_on_mordida_frame_changed"))

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador":
		mordida.visible = true
		animated_sprite_2d.visible = false
		GameManager._recibirDaño(1) 
		mordida.play("Mordida")

func _on_mordida_frame_changed() -> void:
	var frame_actual = mordida.frame
	if frame_actual >= inicio_frame and frame_actual <= fin_frame:
		collision_shape_2d.disabled = false  # Activa el collider
	else:
		collision_shape_2d.disabled = true   # Desactiva el collider
