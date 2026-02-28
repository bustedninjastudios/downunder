extends CharacterBody2D

@export var move_speed: float = 200.0
@export var acceleration: float = 20.0

var target_velocity: Vector2 = Vector2.ZERO

var drill_power: int = 1
var bombs: int = 3
var money: int = 0

func _ready() -> void:
	collision_mask = 1
	
	if SceneTransition.has_spawn_pos:
		global_position = SceneTransition.pending_spawn_pos + SceneTransition.pending_push_offset
		SceneTransition.has_spawn_pos = false
		SceneTransition.pending_spawn_pos = Vector2.ZERO
		SceneTransition.pending_push_offset = Vector2.ZERO
	
	load_state()

func load_state() -> void:
	drill_power = PlayerState.drill_power
	bombs = PlayerState.bombs
	money = PlayerState.money

func save_state() -> void:
	PlayerState.drill_power = drill_power
	PlayerState.bombs = bombs
	PlayerState.money = money

var click_target: Vector2 = Vector2.ZERO
var is_moving_to_click: bool = false
var is_holding: bool = false

func _physics_process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		click_target = get_global_mouse_position()
		is_moving_to_click = true
	
	is_holding = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if Input.is_action_just_pressed("use_item"):
		try_drill()
	
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

func try_drill() -> void:
	var tilemap = get_tilemap()
	if not tilemap:
		return
	
	var mouse_pos = get_global_mouse_position()
	var to_mouse = mouse_pos - global_position
	var distance = to_mouse.length()
	
	if distance > 80 or distance < 16:
		return
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, mouse_pos, 1)
	var result = space_state.intersect_ray(query)
	
	if result and result.collider is TileMapLayer:
		var local_pos = tilemap.to_local(result.position)
		var tile_pos = tilemap.local_to_map(local_pos)
		
		for x in range(-2, 2):
			for y in range(-1, 2):
				var target_tile = tile_pos + Vector2i(x, y)
				if tilemap.get_cell_tile_data(target_tile):
					tilemap.erase_cell(target_tile)
					PlayerState.add_item("stone", 1)
		
		save_state()

func get_tilemap() -> TileMapLayer:
	var root = get_tree().current_scene
	if root and root.has_node("Scene/MainLayer"):
		return root.get_node("Scene/MainLayer")
	return null

func add_money(amount: int) -> void:
	money += amount
	save_state()

func use_bomb() -> bool:
	if bombs > 0:
		bombs -= 1
		save_state()
		return true
	return false

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
