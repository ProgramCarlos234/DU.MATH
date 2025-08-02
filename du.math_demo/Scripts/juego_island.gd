extends Node2D

# Variables para el sistema de puntaje
var puntaje_real: int = 0  # El puntaje real acumulado
var ultimo_valor: int = 0  # El último valor que tocó al jugador

# Referencias a los nodos
@onready var texto_operacion: Label = $Jugador/TextoOperacion
@onready var spawner: Node2D = $SpawnerIsla

func _ready():
	# Verificar nodos
	if not texto_operacion:
		texto_operacion = find_child("TextoOperacion", true, false)
	
	if not spawner:
		spawner = find_child("SpawnerIsla", true, false)
	
	# Conectar la señal del spawner (ahora recibe el tipo)
	if spawner and spawner.has_signal("npc_toco_jugador"):
		spawner.npc_toco_jugador.connect(_on_npc_toco_jugador)
		print("Señal del spawner conectada correctamente")
	
	# Mostrar texto inicial
	mostrar_valor_inicial()

# Esta función se ejecuta cuando un Brain toca al jugador
func _on_npc_toco_jugador(tipo_brain: String):
	var valor_obtenido: int = 0
	
	# Calcular valor según el tipo de Brain
	match tipo_brain:
		"npc":
			# BrainNPC suma aleatoriamente +1 a +9
			valor_obtenido = randi_range(1, 5)
			print("BrainNPC tocó al jugador: +", valor_obtenido)
		
		"evil":
			# BrainEvil resta aleatoriamente -1 a -8
			valor_obtenido = -randi_range(1, 4)
			print("BrainEvil tocó al jugador: ", valor_obtenido)
		
		_:
			print("Tipo de brain desconocido: ", tipo_brain)
			return
	
	# Guardar el último valor y actualizar puntaje real
	ultimo_valor = valor_obtenido
	puntaje_real += valor_obtenido
	
	print("Valor obtenido: ", valor_obtenido)
	print("Puntaje real acumulado: ", puntaje_real)
	
	# Mostrar SOLO el valor que tocó (no la operación real)
	mostrar_ultimo_valor()

# Mostrar solo el último valor que tocó al jugador
func mostrar_ultimo_valor():
	if texto_operacion:
		if ultimo_valor > 0:
			texto_operacion.text = "+" + str(ultimo_valor)
		else:
			texto_operacion.text = str(ultimo_valor)  # Ya incluye el signo -
		
		print("Label actualizado con valor: ", texto_operacion.text)

# Mostrar texto inicial
func mostrar_valor_inicial():
	if texto_operacion:
		texto_operacion.text = "0"

# Función para mostrar la operación real (usar más tarde)
func mostrar_operacion_real():
	if texto_operacion:
		texto_operacion.text = "Total: " + str(puntaje_real)
		print(" Mostrando operación real: ", puntaje_real)

# Funciones de utilidad
func obtener_puntaje_real() -> int:
	return puntaje_real

func obtener_ultimo_valor() -> int:
	return ultimo_valor

func reiniciar_puntaje():
	puntaje_real = 0
	ultimo_valor = 0
	mostrar_valor_inicial()
	print("Sistema de puntaje reiniciado")
