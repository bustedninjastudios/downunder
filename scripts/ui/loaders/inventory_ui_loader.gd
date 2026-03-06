extends Node

# Singleton it is. I LOVE SINGLETYONSNSS!!! IM GOING TO HANG MYSELF

var ui_instance: Control

func _ready() -> void:
	var scene_resource = load("res://scenes/ui/inventory_ui.tscn")
	if scene_resource:
		ui_instance = scene_resource.instantiate()
		# Add to root so it persists across scene changes
		get_tree().root.call_deferred("add_child", ui_instance)
		ui_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui_instance.visible = false
