extends Control

@export var siguiente_escena: PackedScene

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interactuar"):
		print("Se presionó Interactuar")
		get_tree().change_scene_to_file("res://Scenas/ScenasEntorno/menu.tscn")
		
func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_packed(siguiente_escena)
	pass # Replace with function body.
