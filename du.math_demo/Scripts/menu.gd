extends Node2D

@onready var menu_button: MenuButton = $JUGAR_BUTTON
@onready var Salida_button: MenuButton = $SALIR_BUTTON
@onready var Controles: MenuButton = $CONTROLES_BUTTON


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if menu_button.button_pressed:
		get_tree().change_scene_to_file("res://Scenas/ScenasEntorno/Introduccion_comic.tscn")
	
	elif Salida_button.button_pressed:
		get_tree().quit()
		
	elif Controles.button_pressed:
		get_tree().change_scene_to_file("res://Scenas/ScenasEntorno/menuConfiguracion.tscn")
	pass
