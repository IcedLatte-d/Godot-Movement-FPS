class_name IdlePlayerState extends PlayerMovementState

@export var SPEED : float = 5.0
@export var ACCELERATION : float = 0.3
@export var DECELERATION : float = 0.2
@export var TOP_ANIM_SPEED : float = 2.0

func enter(previous_state) -> void:
	ANIMATION.pause()

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
	if PLAYER.velocity.length() > 0.0 and PLAYER.is_on_floor():
		transition.emit("WalkingPlayerState")
