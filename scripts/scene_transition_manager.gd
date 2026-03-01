extends Node

var pending_entrance: String = ""
var pending_push_offset: Vector2 = Vector2.ZERO
var is_transitioning: bool = false

func transition_to(scene_path: String, entrance_name: String) -> void:
	var push_offset := Vector2.ZERO
	if is_transitioning:
		return
	is_transitioning = true
	pending_entrance = entrance_name
	pending_push_offset = push_offset
	
	call_deferred("_deferred_change_scene", scene_path)
	
func _deferred_change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
