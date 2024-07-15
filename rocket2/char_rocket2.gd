extends CharacterBody2D

var max_thrust: float = 500.0
var max_speed: float = 400.0  # Define the maximum speed
var rotation_speed: float = 3.0
var gravity_transition_speed: float = 2.0  # Control the speed of gravity transition

@onready var thrust_particles = $prt_thrust
@onready var snd_thrust_fwd = $snd_thrust_fwd
@onready var snd_thrust_reverse = $snd_thrust_reverse
@onready var weapon = $obj_weapon_default  # Reference to the weapon node

var current_thrust: float = 0.0
var target_gravity: Vector2 = Vector2.ZERO
var current_gravity: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Initialize particles to be off and set gravity to zero
	thrust_particles.emitting = false
	thrust_particles.gravity = Vector2.ZERO
	thrust_particles.lifetime = 0.5  # Adjusted lifetime
	thrust_particles.preprocess = 0.3  # Preprocess to have some particles at start

	# Set randomness for particle lifetime to make them fade out more naturally
	thrust_particles.lifetime_randomness = 0.2
	thrust_particles.color_ramp = create_color_ramp()

func _physics_process(delta: float) -> void:
	handle_rotation(delta)
	handle_thrust(delta)
	handle_shooting()
	update_particle_gravity(delta)
	apply_movement(delta)

func handle_rotation(delta: float) -> void:
	if Input.is_action_pressed("rotate_left"):
		rotation -= rotation_speed * delta
	elif Input.is_action_pressed("rotate_right"):
		rotation += rotation_speed * delta

func handle_thrust(delta: float) -> void:
	if Input.is_action_pressed("thrust_forward"):
		if not snd_thrust_fwd.playing:
			snd_thrust_fwd.play()
		if snd_thrust_reverse.playing:
			snd_thrust_reverse.stop()

		current_thrust = min(current_thrust + max_thrust * delta, max_thrust)
		var thrust_direction = Vector2(cos(rotation), sin(rotation))
		velocity += thrust_direction * current_thrust * delta

		# Ensure particles are set to emit
		thrust_particles.emitting = true

		# Adjust target gravity based on thrust direction
		target_gravity = -thrust_direction * lerp(75.0, 200.0, current_thrust / max_thrust)

	elif Input.is_action_pressed("thrust_backward"):
		if not snd_thrust_reverse.playing:
			snd_thrust_reverse.play()
		if snd_thrust_fwd.playing:
			snd_thrust_fwd.stop()

		current_thrust = max(current_thrust - max_thrust * delta, -max_thrust)
		var reverse_thrust_direction = Vector2(cos(rotation), sin(rotation))
		velocity -= reverse_thrust_direction * abs(current_thrust) * delta

		# Do not emit particles for reverse thrust
		thrust_particles.emitting = false

	else:
		if snd_thrust_fwd.playing:
			snd_thrust_fwd.stop()
		if snd_thrust_reverse.playing:
			snd_thrust_reverse.stop()

		current_thrust = 0
		thrust_particles.emitting = false

	# Clamp the velocity to the maximum speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

func handle_shooting() -> void:
	if Input.is_action_just_pressed("shoot"):
		print("shooting")
		weapon.shoot()

func update_particle_gravity(delta: float) -> void:
	# Smoothly interpolate the gravity towards the target gravity
	current_gravity = current_gravity.lerp(target_gravity, gravity_transition_speed * delta)
	thrust_particles.gravity = current_gravity

func apply_movement(delta: float) -> void:
	velocity *= pow(0.99, delta)  # Apply friction adjusted by delta
	move_and_slide()

func create_color_ramp() -> Gradient:
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 0.5, 0.0, 1.0))  # Bright yellow/orange at start
	gradient.add_point(0.5, Color(1.0, 0.5, 0.0, 1.0))  # Bright yellow/orange in the middle
	gradient.add_point(0.75, Color(0.3, 0.3, 0.3, 1.0))  # Darker grey towards the end
	gradient.add_point(1.0, Color(0.3, 0.3, 0.3, 0.0))  # Fully transparent dark grey at the end
	return gradient
