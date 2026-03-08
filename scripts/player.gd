extends CharacterBody2D

@export var move_speed: float = 300.0
@export var acceleration: float = 20.0

var target_velocity: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite
func _ready() -> void:
	# Terrain tiles have their collision mask to 1. Same number cant collide
	collision_mask = 1
	# process_frame waits until physics process, before render.
	await get_tree().process_frame
	
	# Teleportations
	if SceneTransitionManager.is_transitioning:
		var entrance_name = SceneTransitionManager.pending_entrance
		var entrance = get_tree().current_scene.find_child(entrance_name, true, false)
		if entrance and entrance is Marker2D:
			global_position = entrance.global_position
		SceneTransitionManager.is_transitioning = false
		
	# Load blocks player mined.
	var tilemap = get_tilemap()
	if not tilemap:
		return
	
	var scene_name = get_tree().current_scene.scene_file_path.get_file().get_basename()
	var mined_positions = PlayerState.get_mined_tiles(scene_name)
	
	for tile_pos in mined_positions:
		tilemap.erase_cell(tile_pos)


#var click_target: Vector2 = Vector2.ZERO
var is_moving_to_click: bool = false
var is_holding: bool = false
var drill_cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	is_holding = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if drill_cooldown > 0:
		drill_cooldown -= delta
	
	var drilling = Input.is_action_pressed("use_item") or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	if drilling and drill_cooldown <= 0:
		try_drill()
		drill_cooldown = get_scaled_drill_rate()
	
	var direction := Vector2.ZERO
	
	# Mouse input
	if is_holding:
		var to_mouse := get_global_mouse_position() - global_position
		if to_mouse.length() > 8:
			direction = to_mouse.normalized()
			is_moving_to_click = false
	
	# Keyboard input
	if direction == Vector2.ZERO:
		# Nice shortcut method that works well with our input maps.
		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input_dir.length() > 0:
			is_moving_to_click = false
			direction = input_dir
	
	target_velocity = direction * get_scaled_move_speed()
	
	var accel := acceleration + PlayerState.drill_power * 1.5
	velocity = velocity.lerp(target_velocity, accel * delta)
	
	if velocity.length() > 1:
		rotation = velocity.angle()
		if velocity.x > 0:
			sprite.flip_v = false
		else:
			sprite.flip_v = true
	move_and_slide()

func try_drill() -> void:
	var tilemap = get_tilemap()
	if not tilemap:
		return
	
	var mouse_pos = get_global_mouse_position()
	var to_mouse = mouse_pos - global_position
	var distance = to_mouse.length()
	
	var drill_target: Vector2
	# Automine. Convenient for AFK, although the game isn't 
	# long enough to justify AFKing.
	if distance <= get_drill_reach() and distance >= 16:
		drill_target = mouse_pos
	else:
		drill_target = global_position + Vector2.from_angle(rotation) * get_drill_reach()
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, drill_target, 1)
	var result = space_state.intersect_ray(query)
	
	if result and result.collider is TileMapLayer:
		var local_pos = tilemap.to_local(result.position)
		var tile_pos = tilemap.local_to_map(local_pos)
		
		var radius = get_drill_radius()

		# This was written by AI, given i had zero intention of manually writing all ts shit
		for x in range(-2 - radius, 2 + radius):
			for y in range(-1 - radius, 2 + radius):
				var target_tile = tile_pos + Vector2i(x, y)
				var tile_data = tilemap.get_cell_tile_data(target_tile)
				if tile_data:
					var terrain_set = tile_data.terrain_set
					var terrain = tile_data.terrain
					var required_power = 1
					var ore_type = "sand"
					
					if terrain_set == 0:
						if terrain == 0:
							ore_type = "sand"
							required_power = 1
						elif terrain == 1:
							ore_type = "soft_rock"
							required_power = 2
						elif terrain == 2:
							ore_type = "hard_rock"
							required_power = 3
						elif terrain == 3:
							ore_type = "ultra_hard_rock"
							required_power = 4
					elif terrain_set == 1:
						if terrain == 0:
							ore_type = "soft_copper"
							required_power = 1
						elif terrain == 1:
							ore_type = "soft_iron"
							required_power = 2
						elif terrain == 2:
							ore_type = "soft_gold"
							required_power = 2
					elif terrain_set == 2:
						if terrain == 0:
							ore_type = "hard_copper"
							required_power = 3
						elif terrain == 1:
							ore_type = "hard_iron"
							required_power = 3
						elif terrain == 2:
							ore_type = "hard_gold"
							required_power = 3
					
					if PlayerState.drill_power >= required_power:
						tilemap.erase_cell(target_tile)
						PlayerState.add_item(ore_type, 1)
						var scene_name = get_tree().current_scene.scene_file_path.get_file().get_basename()
						PlayerState.add_mined_tile(scene_name, target_tile)
		

func get_tilemap() -> TileMapLayer:
	var root = get_tree().current_scene
	if root and root.has_node("Scene/MainLayer"):
		return root.get_node("Scene/MainLayer")
	return null
	
#region Player stat scaling
func get_drill_reach() -> float:
	var level = PlayerState.drill_power
	return 48.0 + (level - 1) * 10.0
	
func get_drill_radius() -> int:
	return clamp((PlayerState.drill_power - 1) / 2, 0, 2)
	
func get_scaled_move_speed() -> float:
	var level = PlayerState.drill_power
	return move_speed + (level - 1) * 30

func get_scaled_drill_rate() -> float:
	var level = PlayerState.drill_power
	return max(0.05, 0.15 - level * 0.01)
#endregion
