class_name SceneTransition
extends Area2D

static var pending_spawn_pos: Vector2 = Vector2.ZERO
static var pending_push_offset: Vector2 = Vector2.ZERO
static var has_spawn_pos: bool = false

@export var target_scene: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_do_transition.call_deferred(body)

func _do_transition(player: CharacterBody2D) -> void:
	if target_scene.is_empty():
		return
	
	var screen_width = 1920
	var screen_height = 960
	
	var exit_pos = player.global_position
	var enter_x = abs(exit_pos.x - screen_width)
	var enter_y = exit_pos.y
	
	var push_offset := Vector2.ZERO
	if exit_pos.x > screen_width / 2:
		push_offset.x = 50
	else:
		push_offset.x = -50
	
	pending_spawn_pos = Vector2(enter_x, enter_y)
	pending_push_offset = push_offset
	has_spawn_pos = true
	
	get_tree().change_scene_to_file(target_scene)
