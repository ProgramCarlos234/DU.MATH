extends Node2D


func _on_greiniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://ESCENAS/JUEGO.tscn")


func _on_gsalir_pressed() -> void:
	get_tree().quit()
