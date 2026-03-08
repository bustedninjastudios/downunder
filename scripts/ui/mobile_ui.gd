extends Node

func _ready() -> void:
	# Destroy and free mobile UI button if on PC
	if not DisplayServer.is_touchscreen_available():
		$Dig.queue_free()
	else:
		$Dig.button_down.connect(down)
		$Dig.button_up.connect(up)
		
func down():
	PlayerState.is_mining = true
func up():
	PlayerState.is_mining = false
	
