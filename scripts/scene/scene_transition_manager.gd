extends Node

# Why a manager?
# Rooms can have multiple entrances and exits. While we could just bring the player 
# to the opposite edge of the screen, that is not flexible enough.
# That is however very dumb and stupid, there really shouldn't be a middleman for simple teleports.
# However its "good enough" 

var pending_entrance: String = ""
var is_transitioning: bool = false

func transition_to(scene_path: String, entrance_name: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	pending_entrance = entrance_name

	call_deferred("_deferred_change_scene", scene_path)
	
func _deferred_change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
