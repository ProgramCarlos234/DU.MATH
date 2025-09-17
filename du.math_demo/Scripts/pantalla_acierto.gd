extends Node2D
@onready var menu_button: MenuButton = $Op1

var respuesta_correcta: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if menu_button.button_pressed:
		get_tree().change_scene_to_file("res://Scenas/ScenasEntorno/Mapa_juego.tscn")
		GameManager.LLaves_Conseguidas = GameManager.LLaves_Conseguidas + 1
	pass
	
	
