extends Node2D
func _on_player_died():
	get_tree().change_scene_to_file("res://ESCENAS/Derrota.tscn")
func _on_player_won():
	get_tree().change_scene_to_file("res://ESCENAS/Victoria.tscn")
