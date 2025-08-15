extends Node2D

@onready var Button_Pantalla: MenuButton = $Op1

@export var Indicador_Sub_niveles:int

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Button_Pantalla.button_pressed:
		GameManager._AbrirEscenas(Indicador_Sub_niveles)
	pass
