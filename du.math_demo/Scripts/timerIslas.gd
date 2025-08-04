extends Timer

@export var tiempo_inicial: int = 120
var tiempo_restante: int = 0

@onready var tiempo_contador: Label = $"../TiempoContador"

func _ready():
	print("=== INICIALIZANDO TIMER ===")
	
	# Configurar timer
	wait_time = 1.0  # 1 segundo
	timeout.connect(_on_timer_timeout)
	
	# Iniciar countdown
	tiempo_restante = tiempo_inicial
	actualizar_display()
	start()
	print("Timer iniciado con ", tiempo_inicial, " segundos")

func _on_timer_timeout():
	tiempo_restante -= 1
	actualizar_display()
	
	if tiempo_restante <= 0:
		stop()
		print("¡TIEMPO TERMINADO!")

func actualizar_display():
	if tiempo_contador:
		var minutos = tiempo_restante / 60
		var segundos = tiempo_restante % 60
		tiempo_contador.text = "Tiempo: %02d:%02d" % [minutos, segundos]
	else:
		print("❌ No se encontró TiempoContador")
