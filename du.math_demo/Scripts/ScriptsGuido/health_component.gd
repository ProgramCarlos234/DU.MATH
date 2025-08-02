class_name HealthComponent extends Node2D

signal death()

@export var progress_bar: ProgressBar
@export var current_health := 100
@export var max_healt := 100

func update_health_bar():
	if progress_bar:
		progress_bar.value = current_health
		
func receive_damage(amount: int):
	current_health = clamp(current_health - amount, 0, max_healt)
	update_health_bar()
		
	if current_health <=0:
		on_death()
			
func apply_health(amount: int):
	current_health = clamp(current_health + amount, 0, max_healt)
	update_health_bar()
	
func on_death():
	death.emit()
	
