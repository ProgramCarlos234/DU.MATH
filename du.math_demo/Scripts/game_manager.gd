extends Node

# ======================= #
#       VARIABLES         #
# ======================= #

var DentroArea := false
var VidaJugador: int = 10
var IQJugador: int = 40
var Cantidad_Puntaje_Nivel_Island: int
var JugadorRecibeDaño = false
var paredes: Array = []
var indice_actual := 0
var llave_conseguida = false
var LLaves_Conseguidas: int = 0
var Escenas_Recientes: Array = []  # Array para almacenar las escenas recientes

# ============================ #
#    VARIABLES LLAVES ESCENAS  #
# ============================ #

# ======================= #
#    RUTAS DE ESCENAS     #
# ======================= #

const MAPA_JUEGO_PATH = "res://Scenas/ScenasEntorno/Mapa_juego.tscn"
const ENTORNO_RPG_PATH = "res://Scenas/ScenasEntorno/EntornoRPG.tscn"
const ENTORNO_PLATAFORMAS_PATH = "res://Scenas/ScenasEntorno/EntornoPlataformas.tscn"
const NIVEL_1_MOVER_CAJAS_PATH = "res://Scenas/ScenasEntorno/Nivel1_MoverCajas.tscn"
const MAPA_JUEGO_ISLAND_PATH = "res://Scenas/ScenasEntorno/Mapa_juego_Island.tscn"
const PANTALLA1JUEGOISLAND_PATH = "res://Scenas/ScenasEntorno/Pantalla1Island.tscn"
const SUB_NIVELES_PATH = "res://Scenas/ScenasEntorno/sub_niveles.tscn"
const NIVEL_1_2_DIVISORES_PATH = "res://Scenas/ScenasEntorno/Nivel1_2Divisores.tscn"
const INTRODUCCION_SUB_NIVELES_PATH = "res://Scenas/ScenasEntorno/introduccion_sub_niveles.tscn"
const PANTALLA_GANASTE_PATH = "res://Scenas/ScenasEntorno/pantalla_ganaste.tscn"
const MENU_PRINCIPAL_PATH = "res://Scenas/ScenasEntorno/menu.tscn"
const JEFE_FINAL_PATH = "res://Scenas/ScenasJefe/JefeFinal.tscn"
const PANTALLA_GANASTE_SUB_NIVEL_PATH = "res://Scenas/ScenasEntorno/pantalla_ganaste_sub_nivel.tscn"
const VIDEO_JEFE_PATH = "res://Scenas/ScenasEntorno/VideoJefe.tscn"
const PANTALLA_PERDISTE_PATH = "res://Scenas/ScenasEntorno/pantalla_perdiste.tscn"  # Asegúrate de agregar esta ruta

# Array con las rutas de las escenas
var EscenasPaths: Array = [
	MAPA_JUEGO_PATH,   #0
	ENTORNO_RPG_PATH,   #1
	ENTORNO_PLATAFORMAS_PATH, #2
	NIVEL_1_MOVER_CAJAS_PATH,  #3
	MAPA_JUEGO_ISLAND_PATH,    #4
	PANTALLA1JUEGOISLAND_PATH,  #5
	SUB_NIVELES_PATH,    #6
	NIVEL_1_2_DIVISORES_PATH,   #7
	INTRODUCCION_SUB_NIVELES_PATH,  #8
	PANTALLA_GANASTE_PATH,   #9
	MENU_PRINCIPAL_PATH,  #10
	JEFE_FINAL_PATH,  #11
	PANTALLA_GANASTE_SUB_NIVEL_PATH, #12
	VIDEO_JEFE_PATH,  #13
	PANTALLA_PERDISTE_PATH  #14 - Agregar la pantalla de perdiste
]

# ======================= #
#        _READY           #
# ======================= #
func _ready() -> void:
	# Para HTML5: precargar las escenas críticas
	if OS.has_feature("web"):
		_preload_critical_scenes()
	await get_tree().process_frame

# Precargar escenas críticas para HTML5
func _preload_critical_scenes():
	ResourceLoader.load_threaded_request(MAPA_JUEGO_PATH)
	ResourceLoader.load_threaded_request(MENU_PRINCIPAL_PATH)
	ResourceLoader.load_threaded_request(PANTALLA_GANASTE_PATH)

# ============================== #
#  FUNCIÓN PARA ABRIR ESCENAS    #
# ============================== #
func _AbrirEscenas(valor: int, es_pantalla_perdiste: bool = false) -> void:
	print("Intentando abrir escena con valor: ", valor)
	
	# Guardar la escena actual antes de cambiarla (excepto si es la pantalla de perdiste)
	if not es_pantalla_perdiste and get_tree().current_scene:
		var escena_actual = get_tree().current_scene.scene_file_path
		var indice_actual = EscenasPaths.find(escena_actual)
		
		# Solo guardar si no es la pantalla de perdiste y no está vacía
		if indice_actual != -1 and indice_actual != EscenasPaths.find(PANTALLA_PERDISTE_PATH):
			# Agregar a escenas recientes si no es la misma que la última
			if Escenas_Recientes.is_empty() or Escenas_Recientes.back() != indice_actual:
				Escenas_Recientes.append(indice_actual)
				# Limitar el historial a un número razonable (ej. 10)
				if Escenas_Recientes.size() > 10:
					Escenas_Recientes.pop_front()
	
	if valor >= 0 and valor < EscenasPaths.size():
		var escena_path: String = EscenasPaths[valor]
		print("🌐 Cambiando a escena: ", escena_path)
		
		var error = get_tree().change_scene_to_file(escena_path)
		
		if error != OK:
			print("❌ Error al cambiar de escena: ", error)
			_cargar_escena_manual(escena_path)
	else:
		push_warning("⚠️ Valor de escena inválido: " + str(valor))

# Obtener la última escena antes de la pantalla de perdiste
func _ObtenerUltimaEscena() -> int:
	if Escenas_Recientes.is_empty():
		return 0  # Volver al mapa principal por defecto
	else:
		return Escenas_Recientes.back()

# Método alternativo para cargar escenas si el principal falla
func _cargar_escena_manual(escena_path: String):
	print("Intentando carga manual de: ", escena_path)
	
	var escena = ResourceLoader.load(escena_path)
	if escena:
		var escena_instancia = escena.instantiate()
		get_tree().current_scene.free()
		get_tree().root.add_child(escena_instancia)
		get_tree().current_scene = escena_instancia
		print("✅ Escena cargada manualmente con éxito")
	else:
		print("❌ Error: No se pudo cargar la escena: ", escena_path)

func _recibirDaño(Daño : int) -> void:
	VidaJugador -= Daño
	JugadorRecibeDaño = true

func _CalcularValor_Nivel_Island(Cantidad : int) -> void:
	Cantidad_Puntaje_Nivel_Island += Cantidad

# ============================== #
#   MOVIMIENTO DE PAREDES PUAS   #
# ============================== #
func iniciar_movimiento_paredes():
	var contenedor = get_tree().current_scene.get_node("Nivel1/Paredes")
	if contenedor:
		paredes = contenedor.get_children()
		indice_actual = 0

		if paredes.size() > 0:
			conectar_y_mover(paredes[0])
	else:
		push_warning("No se encontró el nodo 'Nivel1/Paredes'")

func conectar_y_mover(pared_puas):
	if pared_puas and pared_puas.has_node("Pared"):
		var pared_real = pared_puas.get_node("Pared")
		if pared_real.has_signal("movimiento_terminado"):
			pared_real.connect("movimiento_terminado", Callable(self, "_on_pared_movida"))
			pared_real.iniciar_movimiento()
		else:
			push_warning("La pared no tiene señal 'movimiento_terminado'")
	else:
		push_warning("Estructura de pared incorrecta")

func _on_pared_movida():
	indice_actual += 1
	if indice_actual < paredes.size():
		conectar_y_mover(paredes[indice_actual])
