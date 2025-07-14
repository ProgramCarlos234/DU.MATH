extends Node2D

@onready var musica = $AudioStreamPlayer2D

func _ready() -> void:
	musica.play()
