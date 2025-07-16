extends Label

func _ready():
	# Conectamos correctamente la señal al método _on_number_changed
	GameManager.connect("number_changed", Callable(self, "_on_number_changed"))
	
	# Establecemos el valor inicial del Label
	self.text = str(GameManager.get_current_number())

# Función que se ejecuta cuando cambia el número
func _on_number_changed(new_number: int):
	self.text = str(new_number)
	print("Número actualizado en el Label: ", new_number)  # Opcional: para depuración

# Función de ejemplo para probar el cambio desde el Label (opcional)
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Al presionar Enter/Espacio
		# Genera un nuevo número aleatorio (esto es solo para pruebas)
		GameManager.generate_random_number()
