extends Node2D
@onready var menu_button: MenuButton = $MenuButton
@onready var menu_button_2: MenuButton = $MenuButton2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if menu_button.button_pressed:
		get_tree().change_scene_to_file("res://Scenas/ScenasEntorno/EntornoRPG.tscn")
		
	if menu_button_2.button_pressed:
		tree_exited
	pass
