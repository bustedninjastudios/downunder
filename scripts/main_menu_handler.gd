extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#DisplayServer.window_set_size(Vector2i(1920, 1080))
	#Window.size = Vector2i(1920, 1080)
	$StartButton.pressed.connect(on_btn_click)

func on_btn_click() -> void:
	get_tree().change_scene_to_file("res://scenes/area_1.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
