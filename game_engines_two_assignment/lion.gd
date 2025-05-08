extends CharacterBody3D

@export var max_speed: float = 6.0
@export var acceleration: float = 20.0
@export var gravity: float = 30.0
@export var draw_gizmos := false

var vertical_velocity: float = 0.0
var target_zebra: CharacterBody3D = null
var projected: Vector3 = Vector3.ZERO

func _ready():
	add_to_group("lions")

func _physics_process(delta):
	if not target_zebra or not is_instance_valid(target_zebra):
		_find_nearest_zebra()

	if target_zebra:
		_pursue_target(delta)

	_apply_gravity(delta)
	_move_and_face()

func _find_nearest_zebra():
	var zebras = get_tree().get_nodes_in_group("zebras")
	var nearest_dist = INF
	var nearest = null

	for zebra in zebras:
		if not zebra or zebra == self:
			continue
		var dist = global_transform.origin.distance_to(zebra.global_transform.origin)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = zebra

	target_zebra = nearest

func _pursue_target(delta):
	var to_target = target_zebra.global_transform.origin - global_transform.origin
	var distance = to_target.length()

	# Predict where the zebra will be
	var prediction_time = distance / max_speed
	if "velocity" in target_zebra:
		projected = target_zebra.global_transform.origin + target_zebra.velocity * prediction_time
	else:
		projected = target_zebra.global_transform.origin

	var desired_velocity = (projected - global_transform.origin).normalized() * max_speed
	var steering = desired_velocity - velocity
	velocity += steering.normalized() * acceleration * delta

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
		rotate_y(deg_to_rad(-90))  # If your model faces +X instead of -Z
