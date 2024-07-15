extends Node2D

@export var projectile_scene: PackedScene
@export var cooldown: float = 0.5

@onready var projectile_spawn_point = $mrk_weapon_default

var can_shoot: bool = true

func _ready():
	can_shoot = true

func shoot():
	if can_shoot:
		can_shoot = false
		var projectile = projectile_scene.instantiate()
		
		# Set the position and rotation of the projectile correctly
		projectile.global_position = projectile_spawn_point.global_position
		
		# Calculate the initial direction based on the weapon's rotation
		var direction = Vector2(cos(global_rotation), sin(global_rotation))
		projectile.velocity = direction * projectile.speed
		
		# Set the projectile's rotation based on the weapon's rotation at the time of firing
		projectile.rotation = global_rotation
		
		# Add the projectile to the grandparent node of the weapon
		get_parent().get_parent().add_child(projectile)
		
		await get_tree().create_timer(cooldown).timeout
		can_shoot = true
