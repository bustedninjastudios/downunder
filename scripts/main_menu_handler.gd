extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var manager = load("res://scripts/input_manager.gd").new()
	manager.load_input_map("res://shared/input_config.cfg");
	$StartButton.pressed.connect(on_btn_click)

func on_btn_click() -> void:
	get_tree().change_scene_to_file("res://scenes/area_1.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
