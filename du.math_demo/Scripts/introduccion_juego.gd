extends Control

@export var siguiente_escena: PackedScene

func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_packed(siguiente_escena)
	pass # Replace with function body.
