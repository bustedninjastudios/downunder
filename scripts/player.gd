extends CharacterBody2D

@export var move_speed: float = 200.0
@export var acceleration: float = 20.0

var target_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	collision_mask = 0
var click_target: Vector2 = Vector2.ZERO
var is_moving_to_click: bool = false
var is_holding: bool = false

func _physics_process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		click_target = get_global_mouse_position()
		is_moving_to_click = true
	
	is_holding = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	var direction := Vector2.ZERO
	
	if is_holding:
		var to_mouse := get_global_mouse_position() - global_position
		if to_mouse.length() > 8:
			direction = to_mouse.normalized()
			is_moving_to_click = false
	elif is_moving_to_click:
		var to_target := click_target - global_position
		if to_target.length() > 8:
			direction = to_target.normalized()
		else:
			is_moving_to_click = false
	
	if direction == Vector2.ZERO:
		var input_dir := _get_keyboard_input()
		if input_dir.length() > 0:
			is_moving_to_click = false
			direction = input_dir
	
	target_velocity = direction * move_speed
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	
	if velocity.length() > 1:
		rotation = velocity.angle()
	
	move_and_slide()

func _get_keyboard_input() -> Vector2:
	var direction := Vector2.ZERO
	
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1
	
	return direction.normalized()
