extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador": # Verifica que sea el jugador quien salió
		GameManager._recibirDaño(1)# Desactiva la bandera de interacción en el GameManager
	pass # Replace with function body.
