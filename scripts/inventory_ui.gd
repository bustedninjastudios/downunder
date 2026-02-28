extends CanvasLayer

var panel: Panel
var vbox: VBoxContainer
var item_labels: Dictionary = {}
var drill_level_label: Label

func _ready() -> void:
	_create_ui()

func _create_ui() -> void:
	var font = load("res://fonts/VT323-Regular.ttf")
	
	panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(10, 10)
	panel.size = Vector2(200, 140)
	add_child(panel)
	
	vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)
	
	drill_level_label = Label.new()
	drill_level_label.text = "drill: lvl 1"
	if font:
		drill_level_label.add_theme_font_override("font", font)
	drill_level_label.add_theme_font_size_override("font_size", 32)
	var drill_style = StyleBoxFlat.new()
	drill_style.bg_color = Color(0.3, 0.3, 0.3)
	drill_style.set_corner_radius_all(2)
	drill_style.set_border_width_all(1)
	drill_style.border_color = Color.BLACK
	drill_level_label.add_theme_stylebox_override("normal", drill_style)
	drill_level_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(drill_level_label)
	
	var items = [
		{"name": "copper", "color": Color(0.6, 0.4, 0.2)},
		{"name": "iron", "color": Color(0.9, 0.9, 0.95), "text_color": Color.BLACK},
		{"name": "gold", "color": Color(1.0, 0.85, 0.2), "text_color": Color.BLACK},
	]
	
	for item in items:
		var label = Label.new()
		label.text = item["name"] + ": 0"
		if font:
			label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 32)
		var style = StyleBoxFlat.new()
		style.bg_color = item["color"]
		style.set_corner_radius_all(2)
		style.set_border_width_all(1)
		style.border_color = Color.BLACK
		#style.content_padding_left = 8.0
		#style.content_padding_right = 8.0
		label.add_theme_stylebox_override("normal", style)
		if item.has("text_color"):
			label.add_theme_color_override("font_color", item["text_color"])
		vbox.add_child(label)
		item_labels[item["name"]] = label

func _process(_delta: float) -> void:
	_update_inventory()

func _update_inventory() -> void:
	var inventory = PlayerState.inventory
	
	drill_level_label.text = "drill: lvl " + str(PlayerState.drill_power)
	
	var soft_copper = inventory.get("soft_copper", 0)
	var hard_copper = inventory.get("hard_copper", 0)
	var copper = soft_copper + hard_copper
	
	var soft_iron = inventory.get("soft_iron", 0)
	var hard_iron = inventory.get("hard_iron", 0)
	var iron = soft_iron + hard_iron
	
	var soft_gold = inventory.get("soft_gold", 0)
	var hard_gold = inventory.get("hard_gold", 0)
	var gold = soft_gold + hard_gold
	
	item_labels["copper"].text = "copper: " + str(copper)
	item_labels["iron"].text = "iron: " + str(iron)
	item_labels["gold"].text = "gold: " + str(gold)
