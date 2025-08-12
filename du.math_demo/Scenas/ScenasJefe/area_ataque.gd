extends Area2D

@onready var mordida: AnimatedSprite2D = $Mordida

func _on_body_entered(body: Node2D) -> void:
	mordida.visible=true
	if body.is_in_group("Jugador"):
		GameManager._recibirDaño(1) 
		if mordida.sprite_frames.has_animation("Mordida"):
			mordida.play("Mordida")
