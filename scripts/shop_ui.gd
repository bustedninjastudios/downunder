extends CanvasLayer

var panel: Panel
var vbox: VBoxContainer
var upgrade_buttons: Dictionary = {}
var player_near_base: bool = false
const UPGRADE_COST = 250
var base_position := Vector2(1221.5, 641)
var base_detection_radius := 120.0

func _ready() -> void:
	_create_ui()
	panel.visible = false

func _create_ui() -> void:
	var font = load("res://fonts/VT323-Regular.ttf")
	
	panel = Panel.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -200
	panel.offset_right = 200
	panel.offset_top = -130
	panel.offset_bottom = 130
	add_child(panel)
	
	vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	vbox.add_theme_constant_override("margin_left", 10)
	vbox.add_theme_constant_override("margin_right", 10)
	vbox.add_theme_constant_override("margin_top", 10)
	vbox.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(vbox)
	
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox)
	
	#for i in range(1, 5):
		#var sprite = TextureRect.new()
		#var texture = load("res://sprites/Drill" + str(i) + ".png")
		#sprite.texture = texture
		#sprite.custom_minimum_size = Vector2(40, 40)
		#hbox.add_child(sprite)
	
	var title = Label.new()
	title.text = "DRILL SHOP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if font:
		title.add_theme_font_override("font", font)
	title.add_theme_font_size_override("font_size", 40)
	vbox.add_child(title)
	
	var upgrades = [
		{"name": "copper", "color": Color(0.6, 0.4, 0.2), "text_color": Color.BLACK, "level": 2},
		{"name": "iron", "color": Color(0.9, 0.9, 0.95), "text_color": Color.BLACK, "level": 3},
		{"name": "gold", "color": Color(1.0, 0.85, 0.2), "text_color": Color.BLACK, "level": 4},
	]
	
	for upg in upgrades:
		var btn = Button.new()
		btn.text = "upgrade to lvl " + str(upg["level"]) + " (" + str(UPGRADE_COST) + " " + upg["name"] + ")"
		var icon_texture = load("res://sprites/icons/Drill" + str(upg["level"] - 1) + ".png")
		if icon_texture:
			btn.icon = icon_texture
			btn.expand_icon = true
		if font:
			btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 28)
		
		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = upg["color"]
		style_normal.set_corner_radius_all(4)
		style_normal.set_border_width_all(2)
		style_normal.border_color = Color.BLACK
		btn.add_theme_stylebox_override("normal", style_normal)
		
		var style_hover = StyleBoxFlat.new()
		style_hover.bg_color = upg["color"].lightened(0.2)
		style_hover.set_corner_radius_all(4)
		style_hover.set_border_width_all(2)
		style_hover.border_color = Color.WHITE
		btn.add_theme_stylebox_override("hover", style_hover)
		
		if upg.has("text_color"):
			btn.add_theme_color_override("font_color", upg["text_color"])
			btn.add_theme_color_override("font_hover_color", upg["text_color"])
		
		btn.pressed.connect(_on_upgrade_pressed.bind(upg["name"], upg["level"]))
		vbox.add_child(btn)
		upgrade_buttons[upg["name"]] = btn

func _on_upgrade_pressed(material: String, level: int) -> void:
	var inventory = PlayerState.inventory
	var count = inventory.get("soft_" + material, 0) + inventory.get("hard_" + material, 0)
	
	if count >= UPGRADE_COST and PlayerState.drill_power < level:
		PlayerState.inventory["soft_" + material] = inventory.get("soft_" + material, 0) - UPGRADE_COST
		if PlayerState.inventory["soft_" + material] < 0:
			var remaining = abs(PlayerState.inventory["soft_" + material])
			PlayerState.inventory["hard_" + material] = inventory.get("hard_" + material, 0) - remaining
			PlayerState.inventory["soft_" + material] = 0
			if PlayerState.inventory["hard_" + material] < 0:
				PlayerState.inventory["hard_" + material] = 0
		PlayerState.drill_power = level
		#PlayerState.save()
		_update_buttons()

func _process(_delta: float) -> void:
	var tree = get_tree()
	if not tree.current_scene:
		return
	
	var player = tree.current_scene.get_node_or_null("Player")
	var base = tree.current_scene.get_node_or_null("Base")
	if player and base:
		var dist = player.global_position.distance_to(base_position)
		var was_near = player_near_base
		player_near_base = dist < base_detection_radius
		
		if player_near_base and not was_near:
			_update_buttons()
			panel.visible = true
		elif not player_near_base and was_near:
			panel.visible = false
		
		if player_near_base:
			_update_buttons()

func _update_buttons() -> void:
	var inventory = PlayerState.inventory
	var current_level = PlayerState.drill_power
	
	var upgrades = [
		{"name": "copper", "level": 2},
		{"name": "iron", "level": 3},
		{"name": "gold", "level": 4},
	]
	
	for upg in upgrades:
		var btn = upgrade_buttons[upg["name"]]
		var count = inventory.get("soft_" + upg["name"], 0) + inventory.get("hard_" + upg["name"], 0)
		
		if current_level >= upg["level"]:
			btn.text = "max level"
			btn.disabled = true
			btn.icon = null
		elif count >= UPGRADE_COST:
			btn.text = "upgrade to lvl " + str(upg["level"]) + " ("+str(UPGRADE_COST) + " " + upg["name"] + ")"
			btn.disabled = false
		else:
			btn.text = "need 50 " + upg["name"] + " (" + str(count) + "/"+ str(UPGRADE_COST) + ")"
			btn.disabled = true
