extends Node2D

@onready var Musica = $AudioStreamPlayer2D

func _ready():
	Musica.play()
	
func _on_inicio_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/RPG_Mundo.tscn")
	
