extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# animations
const ANIM_ATTACK: StringName = "attack"
const ANIM_IDLE: StringName = "default"
const ANIM_JUMP: StringName = "jump"
const ANIM_RUN: StringName = "run"

# input keys
const RUN_LEFT: StringName = "run_left"
const RUN_RIGHT: StringName = "run_right"
const JUMP: StringName = "jump"
const ATTACK: StringName = "attack"

enum AnimState {
	RUN,
	JUMP,
	ATTACK,
	IDLE,
}

@export var prev_anim_state: AnimState = AnimState.IDLE
@export var anim_state: AnimState = AnimState.IDLE

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _process(_delta: float):
	# avoid setting the same animation twice
	if prev_anim_state == anim_state:
		return
	
	match anim_state:
		AnimState.RUN:
			animated_sprite_2d.play(ANIM_RUN)
		AnimState.JUMP:
			animated_sprite_2d.play(ANIM_JUMP)
		AnimState.ATTACK:
			animated_sprite_2d.play(ANIM_ATTACK)
		AnimState.IDLE:
			animated_sprite_2d.play(ANIM_IDLE)

func _physics_process(delta: float) -> void:
	prev_anim_state = anim_state
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed(JUMP) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis(RUN_LEFT, RUN_RIGHT)
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	
	# flip sprite to the left if moving to the left; otherwise look right
	if direction:
		animated_sprite_2d.flip_h = direction < 0
	
	if is_zero_approx(velocity.x) and is_zero_approx(velocity.y):
		anim_state = AnimState.IDLE
	elif is_on_floor():
		anim_state = AnimState.RUN
	else:
		anim_state = AnimState.JUMP
	
	if Input.is_action_pressed(ATTACK):
		anim_state = AnimState.ATTACK

	# does all the heavy physics lifting for us
	move_and_slide()
