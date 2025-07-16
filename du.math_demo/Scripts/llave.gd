extends Area2D

@export var portal: NodePath  # Asigna el nodo del portal en el editor
var puede_interactuar := false

func _on_body_entered(body):
	if body.name == "jugador":
		puede_interactuar = true

func _on_body_exited(body):
	if body.name == "jugador":
		puede_interactuar = false

func _process(_delta):
	if puede_interactuar and Input.is_action_just_pressed("Interactuar"):
		var portal_node = get_node(portal)
		if portal_node:
			portal_node.visible = true
			queue_free()
