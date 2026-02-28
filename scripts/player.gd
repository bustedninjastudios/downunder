extends CharacterBody2D

@export var tile_size: Vector2 = Vector2(64, 64)
@export var move_duration: float = 0.15

var is_moving: bool = false
var target_position: Vector2
var tween: Tween

func _ready() -> void:
	position = position.snapped(Vector2(tile_size))
	target_position = position

func _process(_delta: float) -> void:
	if is_moving:
		return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_dir.length() > 0:
		var move_direction := Vector2i.ZERO
		
		if abs(input_dir.x) > abs(input_dir.y):
			move_direction.x = sign(input_dir.x)
		else:
			move_direction.y = sign(input_dir.y)
		
		start_move(move_direction)

func start_move(direction: Vector2i) -> void:
	target_position = position + Vector2(direction) * tile_size
	is_moving = true
	
	tween = create_tween()
	tween.tween_property(self, "position", target_position, move_duration)
	tween.tween_callback(_on_move_complete)

func _on_move_complete() -> void:
	is_moving = false
