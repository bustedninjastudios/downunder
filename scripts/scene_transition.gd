extends Area2D

@export var target_scene: String = ""
@export var two_way: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		transition_to_scene(body)

func transition_to_scene(player: CharacterBody2D) -> void:
	if target_scene.is_empty():
		return
	
	var screen_width = 1920
	var current_x = global_position.x
	
	var new_x: float
	if current_x > screen_width / 2:
		new_x = 32
	else:
		new_x = screen_width - 32
	
	player.global_position = Vector2(new_x, player.global_position.y)
	get_tree().change_scene_to_file(target_scene)
