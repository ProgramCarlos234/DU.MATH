extends Area2D

func _on_body_entered(body: Node) -> void:
	# Verificar si es el jugador (por nombre o tipo)
	if body and (body.name == "Jugador" or body.is_in_group("jugador")):
		var jefe = get_parent().get_node_or_null("Jefe")
		if jefe:
			jefe.visible = true
			if jefe.has_method("iniciar"):
				jefe.iniciar()
			else:
				print("⚠ El jefe no tiene el método 'iniciar'")
		else:
			print("⚠ No se encontró el nodo 'Jefe' en", get_parent())

		# Activar preguntas
		var question_points = get_parent().get_node_or_null("QuestionPoints")
		if question_points:
			for pregunta in question_points.get_children():
				pregunta.visible = true
		else:
			print("⚠ No se encontró el nodo 'QuestionPoints'")
