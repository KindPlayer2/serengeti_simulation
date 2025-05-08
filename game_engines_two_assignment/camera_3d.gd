extends Camera3D

@export var mouse_sensitivity := 0.003
@export var move_speed := 5.0
@export var sprint_multiplier := 2.0
@export var pivot: Node3D

var yaw := 0.0
var pitch := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-85), deg_to_rad(85))

		rotation.y = yaw
		pivot.rotation.x = pitch

	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	var speed = move_speed

	if Input.is_action_pressed("ui_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("ui_right"):
		input_dir += transform.basis.x
	if Input.is_action_pressed("ui_up"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("ui_down"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("jump"):
		input_dir += transform.basis.y
	if Input.is_action_pressed("crouch"):
		input_dir -= transform.basis.y

	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		global_position += input_dir * speed * delta
