extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(body_enter)
	pass # Replace with function body.

func body_enter(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
	pass
