extends Control

@export var siguiente_escena: PackedScene
@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer

var escena_cambiada := false

func _ready() -> void:
	video_player.play()
	# Conectar señal de fin de video
	video_player.finished.connect(_on_video_finished)

func _process(delta: float) -> void:
	if not escena_cambiada and Input.is_action_just_pressed("Interactuar"):
		abrir_siguiente_escena()

func _on_video_finished() -> void:
	if not escena_cambiada:
		abrir_siguiente_escena()

func abrir_siguiente_escena() -> void:
	escena_cambiada = true
	if siguiente_escena:
		get_tree().change_scene_to_packed(siguiente_escena)
