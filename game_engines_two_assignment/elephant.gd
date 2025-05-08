extends CharacterBody3D

@export var wander_radius: float = 60.0
@export var wander_interval: float = 5.0
@export var move_speed: float = 1.5
@export var gravity: float = 30.0

var vertical_velocity: float = 0.0
var wander_timer: float = 0.0
var target_position: Vector3

func _ready():
	_set_new_wander_target()

func _physics_process(delta):
	wander_timer += delta
	if wander_timer >= wander_interval or _reached_target():
		wander_timer = 0.0
		_set_new_wander_target()

	_move_toward_target(delta)
	_apply_gravity(delta)
	_move_and_face()

func _set_new_wander_target():
	var random_dir = Vector3(
		randf_range(-1.0, 1.0),
		0,
		randf_range(-1.0, 1.0)
	).normalized()
	target_position = global_transform.origin + random_dir * wander_radius

func _reached_target() -> bool:
	return global_transform.origin.distance_to(target_position) < 1.0

func _move_toward_target(delta):
	var direction = (target_position - global_transform.origin).normalized()
	direction.y = 0
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

func _apply_gravity(delta):
	if is_on_floor():
		vertical_velocity = 0.0
	else:
		vertical_velocity -= gravity * delta
	velocity.y = vertical_velocity

func _move_and_face():
	move_and_slide()
	var flat_velocity = velocity
	flat_velocity.y = 0
	if flat_velocity.length() > 0.1:
		look_at(global_transform.origin + flat_velocity, Vector3.UP)
		rotate_y(deg_to_rad(-90))  # Adjust if model faces +X
