extends Area2D

var puede_interactuar := false

func _on_body_entered(body):
	if body.name == "Jugador":
		puede_interactuar = true

func _on_body_exited(body):
	if body.name == "Jugador":
		puede_interactuar = false

func _process(_delta):
	if puede_interactuar and Input.is_action_just_pressed("Interactuar"):
		GameManager.llave_conseguida = true
		GameManager.LLaves_Conseguidas += 1
		queue_free()
