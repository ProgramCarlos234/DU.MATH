class_name Enemy extends CharacterBody2D

@onready var sprite_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $Components/HealthComponent

var player: CharacterBody2D
var move_speed := 50
var attack_damage := 10
var is_attack := false
var in_attack_player_range := false

func _ready() -> void:
	player = get_tree().current_scene.get_node_or_null("Jugador") # Buscar al jugador en la escena actual
	
	health_component.death.connect(on_death)
	if player:
		player.attack_finished.connect(verify_receive_damage)
		
func _physics_process(delta: float) -> void:
	if !is_attack:
		sprite_animation.play("run")
		
		var move_direction = (player.position - position).normalized()
		if move_direction:
			velocity = move_direction * move_speed
			if move_direction.x !=0:
				sprite_animation.flip_h = move_direction.x < 0
				$AreaAttack.scale.x = -1 if move_direction.x < 0 else 1
				
		move_and_slide()
		
func attack():
	sprite_animation.play("attack")
	is_attack = true
		
func verify_receive_damage():
	if in_attack_player_range:
		health_component.receive_damage(player.attack_damage)
		
func on_death():
	queue_free()
#Cuando el Player entre a al zona de ataqu

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite_animation.animation == "attack":
		player.health_component.receive_damage(attack_damage)
		if is_attack:
			attack()
