extends TileMapLayer

@export var llaves_necesarias: int  # 🔑 Cambia esto al número de llaves que quieras

func _process(delta: float) -> void:
	if GameManager.LLaves_Conseguidas >= llaves_necesarias:
		queue_free()  # Elimina este nodo
