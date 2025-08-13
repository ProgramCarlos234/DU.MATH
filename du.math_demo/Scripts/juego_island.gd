extends Node2D

# Variables para el sistema de puntaje
var puntaje_real: int = 0  # El puntaje real acumulado
var ultimo_valor: int = 0  # El último valor que tocó al jugador
var penultimo_valor: int = 0  # El valor anterior al último

# Referencias a los nodos
@onready var texto_operacion: Label = $Jugador/TextoOperacion
@onready var texto_operacion2: Label = $Jugador/TextoOperacion2  # Nueva referencia
@onready var spawner: Node2D = $SpawnerIsla
@onready var spawner2: Node2D = $SpawnerIsla2  # Nuevo spawner
@onready var spawner3: Node2D = $NivelNodoIsla/SpawnerIsla3
@onready var spawner4: Node2D = $NivelNodoIsla/SpawnerIsla4

func _ready():
	# Verificar nodos
	if not texto_operacion:
		texto_operacion = find_child("TextoOperacion", true, false)
	
	if not texto_operacion2:
		texto_operacion2 = find_child("TextoOperacion2", true, false)
	
	if not spawner:
		spawner = find_child("SpawnerIsla", true, false)
	
	if not spawner2:
		spawner2 = find_child("SpawnerIsla2", true, false)
	if not spawner3:
		spawner3 = find_child("SpawnerIsla3", true, false)
		
	if not spawner4:
		spawner4 = find_child("SpawnerIsla4",true, false)
	
	# Conectar la señal del primer spawner
	if spawner and spawner.has_signal("npc_toco_jugador"):
		spawner.npc_toco_jugador.connect(_on_npc_toco_jugador)
	
	# Conectar la señal del segundo spawner
	if spawner2 and spawner2.has_signal("npc_toco_jugador"):
		spawner2.npc_toco_jugador.connect(_on_npc_toco_jugador)
		#Spawner3
	if spawner3 and spawner3.has_signal("npc_toco_jugador"):
		spawner3.npc_toco_jugador.connect(_on_npc_toco_jugador)
	
	if spawner4 and spawner4.has_signal("npc_toco_jugador"):
		spawner4.npc_toco_jugador.connect(_on_npc_toco_jugador)
	# Mostrar texto inicial
	mostrar_valor_inicial()

func _process(delta: float) -> void:
	puntaje_real = GameManager.Cantidad_Puntaje_Nivel_Island # igualamos el puntaje al valor del gamemanager
	pass
	
# Esta función se ejecuta cuando un Brain toca al jugador (desde cualquier spawner)
func _on_npc_toco_jugador(tipo_brain: String):
	var valor_obtenido: int = 0
	
	# Calcular valor según el tipo de Brain
	match tipo_brain:
		"npc":
			# BrainNPC suma aleatoriamente +1 a +9
			valor_obtenido = randi_range(1, 9)
		
		"evil":
			# BrainEvil resta aleatoriamente -1 a -8
			valor_obtenido = -randi_range(1, 5)
		
		_:
			return
	
	# Actualizar los valores: el último se convierte en penúltimo
	penultimo_valor = ultimo_valor
	ultimo_valor = valor_obtenido
	
	# Actualizar puntaje real
	GameManager._CalcularValor_Nivel_Island(valor_obtenido)
	
	# Mostrar valores en ambos labels
	mostrar_valores_en_labels()

# Mostrar valores en ambos labels
func mostrar_valores_en_labels():
	# Mostrar el último valor en TextoOperacion
	if texto_operacion:
		if ultimo_valor > 0:
			texto_operacion.text = "+" + str(ultimo_valor)
		else:
			texto_operacion.text = str(ultimo_valor)  # Ya incluye el signo -
	
	# Mostrar el penúltimo valor en TextoOperacion2
	if texto_operacion2:
		if penultimo_valor == 0:
			texto_operacion2.text = ""  # No mostrar nada si no hay valor anterior
		elif penultimo_valor > 0:
			texto_operacion2.text = "+" + str(penultimo_valor)
		else:
			texto_operacion2.text = str(penultimo_valor)  # Ya incluye el signo -

# Mostrar texto inicial
func mostrar_valor_inicial():
	if texto_operacion:
		texto_operacion.text = "0"
	if texto_operacion2:
		texto_operacion2.text = ""  # Vacío inicialmente

# Función para mostrar la operación real (usar más tarde)
func mostrar_operacion_real():
	if texto_operacion:
		texto_operacion.text = "Total: " + str(puntaje_real)

# Funciones de utilidad
func obtener_puntaje_real() -> int:
	return puntaje_real

func obtener_ultimo_valor() -> int:
	return ultimo_valor

func obtener_penultimo_valor() -> int:
	return penultimo_valor

func reiniciar_puntaje():
	puntaje_real = 0
	ultimo_valor = 0
	penultimo_valor = 0
	mostrar_valor_inicial()

func _on_timer_timeout() -> void:
	pass # Replace with function body.
