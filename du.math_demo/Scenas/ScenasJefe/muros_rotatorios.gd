extends Node2D

@export var muro_scene: PackedScene = preload("res://Scenas/ScenasJefe/Muro.tscn")
@export var cantidad_muros: int = 2
@export var radio: float = 100.0       # Radio mayor para que se vea bien
@export var rotation_speed: float = 0.7

func _ready():
	if muro_scene == null:
		push_error("⚠ No se asignó la escena del muro")
		return

	for i in range(cantidad_muros):
		var muro = muro_scene.instantiate()
		add_child(muro)
		
		# Posicionar en círculo
		var angulo = (TAU / cantidad_muros) * i
		muro.position = Vector2(radio, 0).rotated(angulo)
		
		# Asegurar que se vea
		muro.z_index = 10
		
		# Debug: imprimir posición
		print("Muro creado en:", muro.position)
		
		# Reproducir animación si existe
		var sprite = muro.get_node("AnimatedSprite2D")
		if sprite and sprite.sprite_frames.has_animation("muro"):
			sprite.play("muro")
		else:
			print("⚠ Animación 'muro' no encontrada en el muro ", i)

func _process(delta):
	# Rotar el contenedor
	rotation += rotation_speed * delta
