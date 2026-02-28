extends Node

const CONFIG_PATH := "user://input_config.cfg"

func serialize_input_map() -> Dictionary:
	var config := ConfigFile.new()
	var input_map := {}
	
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue
		
		var action_data := {
			"deadzone": InputMap.action_get_deadzone(action),
			"events": []
		}
		
		for event in InputMap.action_get_events(action):
			var event_data := _serialize_event(event)
			if event_data.size() > 0:
				action_data["events"].append(event_data)
		
		input_map[action] = action_data
	
	return input_map

func _serialize_event(event: InputEvent) -> Dictionary:
	var data := {}
	
	if event is InputEventKey:
		data["type"] = "key"
		data["physical_keycode"] = event.physical_keycode
		data["key_label"] = event.key_label
		data["unicode"] = event.unicode
		data["pressed"] = event.pressed
	elif event is InputEventMouseButton:
		data["type"] = "mouse_button"
		data["button_index"] = event.button_index
		data["pressed"] = event.pressed
	elif event is InputEventJoypadButton:
		data["type"] = "joy_button"
		data["button_index"] = event.button_index
		data["device"] = event.device
	elif event is InputEventJoypadMotion:
		data["type"] = "joy_motion"
		data["axis"] = event.axis
		data["axis_value"] = event.axis_value
		data["device"] = event.device
	
	return data

func save_input_map(path: String = CONFIG_PATH) -> bool:
	var input_map := serialize_input_map()
	var config := ConfigFile.new()
	
	for action in input_map:
		config.set_value("input", action, input_map[action])
	
	return config.save(path)

func deserialize_input_map(data: Dictionary) -> void:
	for action in data.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		
		InputMap.action_erase_events(action)
		
		var action_data: Dictionary = data[action]
		if action_data.has("deadzone"):
			InputMap.action_set_deadzone(action, action_data["deadzone"])
		
		for event_data: Dictionary in action_data["events"]:
			var event := _deserialize_event(event_data)
			if event != null:
				InputMap.action_add_event(action, event)

func _deserialize_event(data: Dictionary) -> InputEvent:
	var type: String = data.get("type", "")
	
	if type == "key":
		var event := InputEventKey.new()
		event.physical_keycode = data.get("physical_keycode", 0)
		event.key_label = data.get("key_label", 0)
		event.unicode = data.get("unicode", 0)
		event.pressed = data.get("pressed", false)
		return event
	elif type == "mouse_button":
		var event := InputEventMouseButton.new()
		event.button_index = data.get("button_index", 0)
		event.pressed = data.get("pressed", false)
		return event
	elif type == "joy_button":
		var event := InputEventJoypadButton.new()
		event.button_index = data.get("button_index", 0)
		event.device = data.get("device", 0)
		return event
	elif type == "joy_motion":
		var event := InputEventJoypadMotion.new()
		event.axis = data.get("axis", 0)
		event.axis_value = data.get("axis_value", 0.0)
		event.device = data.get("device", 0)
		return event
	
	return null

func load_input_map(path: String = CONFIG_PATH) -> bool:
	var config := ConfigFile.new()
	var err := config.load(path)
	
	if err != OK:
		return false
	
	var input_map := {}
	
	for action in config.get_section_keys("input"):
		input_map[action] = config.get_value("input", action)
	
	deserialize_input_map(input_map)
	return true
