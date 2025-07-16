extends Node2D


func _on_reiniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/Etapa1_BETA.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit()
