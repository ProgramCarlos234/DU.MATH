extends Node2D

@onready var op_1: MenuButton = $Op1
@onready var op_2: MenuButton = $Op2
@onready var op_3: MenuButton = $Op3

var Opciones_Menu_Island : Array = [
	op_1,
	op_2,
	op_3
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	op_1.text = str(GameManager.Cantidad_Puntaje_Nivel_Island)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
