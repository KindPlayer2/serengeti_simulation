extends CharacterBody3D

enum State { ROAMING, FLEEING }

@export var max_speed: float = 5.0
@export var acceleration: float = 8.0
@export var gravity: float = 30.0
@export var flee_range: float = 10.0  # <- ADJUST THIS TO CHANGE FLEE DISTANCE
@export var head: Node3D

@export var separation_weight: float = 1.0
@export var alignment_weight: float = 1.0
@export var cohesion_weight: float = 1.0

var vertical_velocity: float = 0.0
var state: State = State.ROAMING
var lions: Array = []

# Eating
var is_eating: bool = false
var eat_timer := 0.0
var next_eat_time := randf_range(10.0, 20.0)
var eat_duration := 0.0
var eat_progress := 0.0

var head_start_pos: Vector3
var head_end_pos: Vector3
var head_start_rot: float = deg_to_rad(-45)
var head_end_rot: float = deg_to_rad(45)

func _ready():
	add_to_group("zebras")
	head_start_pos = head.position
	head_end_pos = Vector3(-1.3, -0.25, head.position.z)
	
func _on_body_entered(body):
	if body.is_in_group("lions"):
		global_transform.origin = Vector3(200, 5, 200)
		velocity = Vector3.ZERO
		vertical_velocity = 0.0


func _physics_process(delta):
	if not is_eating:
		lions = get_tree().get_nodes_in_group("lions")
		_update_state()

	var force = Vector3.ZERO
	match state:
		State.ROAMING:
			if is_eating:
				_update_eating(delta)
				return
			_handle_eating_timers(delta)
			force = _calculate_boid_force()
		State.FLEEING:
			force = _calculate_flee_force()
			_stop_eating()

	var desired_velocity = velocity + force * delta * acceleration
	velocity = desired_velocity

	_apply_gravity(delta)
	_move_and_face()

func _update_state():
	var should_flee = false
	for lion in lions:
		if is_instance_valid(lion):
			var dist = global_transform.origin.distance_to(lion.global_transform.origin)
			if dist < flee_range:
				should_flee = true
				break

	if should_flee:
		state = State.FLEEING
	else:
		state = State.ROAMING

func _calculate_flee_force() -> Vector3:
	var flee_force = Vector3.ZERO
	for lion in lions:
		if not is_instance_valid(lion):
			continue
		var to_lion = lion.global_transform.origin - global_transform.origin
		var dist = to_lion.length()
		if dist < flee_range:
			flee_force += (-to_lion.normalized()) * max_speed - velocity
	return flee_force.normalized()

func _calculate_boid_force() -> Vector3:
	var zebras = get_tree().get_nodes_in_group("zebras")
	var separation = Vector3.ZERO
	var alignment = Vector3.ZERO
	var cohesion = Vector3.ZERO
	var count = 0

	for zebra in zebras:
		if zebra == self or not is_instance_valid(zebra):
			continue
		var to_other = zebra.global_transform.origin - global_transform.origin
		var dist = to_other.length()
		if dist < 10.0:
			separation -= to_other.normalized() / dist
			alignment += zebra.velocity
			cohesion += zebra.global_transform.origin
			count += 1

	if count > 0:
		alignment = (alignment / count).normalized() * max_speed - velocity
		cohesion = ((cohesion / count - global_transform.origin).normalized() * max_speed) - velocity
		separation = separation.normalized() * max_speed - velocity

	return separation * separation_weight + alignment * alignment_weight + cohesion * cohesion_weight

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
		rotate_y(deg_to_rad(-90))  # Adjust forward direction

func _handle_eating_timers(delta):
	eat_timer += delta
	if eat_timer >= next_eat_time:
		_start_eating()

func _start_eating():
	is_eating = true
	eat_progress = 0.0
	eat_duration = randf_range(1.0, 3.0)
	eat_timer = 0.0
	next_eat_time = randf_range(10.0, 20.0)

func _update_eating(delta):
	eat_progress += delta
	var t = clamp(eat_progress / eat_duration, 0, 1)

	if t < 0.5:
		var t2 = t * 2.0
		head.position = head_start_pos.lerp(head_end_pos, t2)
		head.rotation.z = lerp(head_start_rot, head_end_rot, t2)
	else:
		var t2 = (t - 0.5) * 2.0
		head.position = head_end_pos.lerp(head_start_pos, t2)
		head.rotation.z = lerp(head_end_rot, head_start_rot, t2)

	if t >= 1.0:
		is_eating = false

func _stop_eating():
	is_eating = false
	head.position = head_start_pos
	head.rotation.z = head_start_rot


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("lions"):
		global_transform.origin = Vector3(200, 5, 200)
		velocity = Vector3.ZERO
		vertical_velocity = 0.0
