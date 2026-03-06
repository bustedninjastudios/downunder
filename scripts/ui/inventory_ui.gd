extends Control


func update_label(child: Control, prefix: String, value: Variant):
	if child and "text" in child:
		child.text = prefix + str(value)
		
func _process(_delta: float) -> void:	
	var scene = get_tree().current_scene
	if not scene:
		return
	
	# Control as root indicates scene is an UI scene. We don't want overlapping UI
	var is_ui_scene = get_tree().current_scene is Control
	
	visible = not is_ui_scene
	
	if visible:
		_update_ui()

func _update_ui() -> void:
	var total_ores = 0
	for count in PlayerState.inventory.values():
		total_ores += count
			
	update_label($Body/Money/Label, "$", PlayerState.money)
	update_label($Body/Drill/Label, "drill lv: ", PlayerState.drill_power)
	update_label($Body/Bombs/Label, "bombs: ", PlayerState.bombs)
	update_label($Body/Radars/Label, "radars: ", PlayerState.radars)
	#update_label($Body/Ores, "ores: ", total_ores)
