class_name Player extends CharacterBody3D

# Exported variables/constants
@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Node3D
@export var ANIMATIONPLAYER : AnimationPlayer

@export var CROUCH_SHAPECAST : ShapeCast3D

# Local variables
var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3

var _current_rotation : float

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event: InputEvent) -> void:
	# Gives tilt and rotation input if the mouse moves
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY

func _update_camera(delta):
	_current_rotation = _rotation_input
	# Rotates camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)

	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	CAMERA_CONTROLLER.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0
	
func _ready():
	Global.player = self # Sets the player referenced by Global to self
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Get mouse input
	CROUCH_SHAPECAST.add_exception($".")

func _input(event):
	# Exit the test
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _physics_process(delta):
	_update_camera(delta)
	Global.debug.add_property("PlayerVelocity","%.2f" % velocity.length(), 2)

func update_gravity(delta) -> void:
	velocity.y -= gravity * delta
	# Prevents player from exceeding terminal velocity (70m/s)
	velocity.y = clamp(velocity.y, -70.0, INF)

func update_input(speed: float, acceleration: float, deceleration: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
	else:
		var vel = Vector2(velocity.x,velocity.z) # From magic YT comments guy to fix weird stopping
		var temp = move_toward(Vector2(velocity.x,velocity.z).length(), 0, deceleration)
		velocity.x = vel.normalized().x * temp
		velocity.z = vel.normalized().y * temp

func update_velocity() -> void:
	move_and_slide()
