extends Area2D

@export var dialogo: DialogueResource             # Diálogo de este NPC
@export var desbloquea_portal: bool = false       # Solo TRUE en el primer NPC
@export var portal_nodepath: NodePath             # Ruta del portal oculto (en la escena)

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Jugador":
		return

	body.can_move = false

	var balloon := DialogueManager.show_example_dialogue_balloon(dialogo)

	# --- Señal 1: fin del diálogo ---
	DialogueManager.dialogue_ended.connect(func(res):
		if res == dialogo and is_instance_valid(body):
			body.can_move = true
			_accion_post_dialogo()
	, CONNECT_ONE_SHOT)

	# --- Señal 2: cierre del globo ---
	balloon.tree_exited.connect(func ():
		if is_instance_valid(body):
			body.can_move = true
			_accion_post_dialogo()
	, CONNECT_ONE_SHOT)

func _accion_post_dialogo():
	# Si este NPC desbloquea portal, lo hacemos visible
	if desbloquea_portal and portal_nodepath != NodePath(""):
		var portal = get_node_or_null(portal_nodepath)
		if portal:
			portal.visible = true

	# Destruir al NPC
	queue_free()
