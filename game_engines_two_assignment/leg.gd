extends MeshInstance3D

@export var rotation_angle_deg := 45.0
@export var speed := 2.0  # Speed of leg swing

var t := 0.0
var direction := 1.0
var base_rotation := 0.0

func _ready():
	base_rotation = rotation.z  # Store the starting rotation

func _process(delta):
	t += delta * speed * direction

	# Reverse direction at ends
	if t >= 1.0:
		t = 1.0
		direction = -1.0
	elif t <= 0.0:
		t = 0.0
		direction = 1.0

	# Calculate lerped rotation between -angle and +angle
	var angle_rad = deg_to_rad(rotation_angle_deg)
	var current_z = lerp(-angle_rad, angle_rad, t)
	rotation.z = base_rotation + current_z
