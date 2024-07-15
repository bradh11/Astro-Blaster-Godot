extends Area2D

@export var speed: float = 800.0
@export var lifetime: float = 2.0

var velocity: Vector2

@onready var collision_shape = $col_bullet_default
@onready var sprite = $spr_bullet_default

func _ready():
	collision_shape.set_deferred("disabled", false)
	if sprite:  # Ensure sprite is not null before setting z_index
		sprite.z_index = 1
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	position += velocity * delta

