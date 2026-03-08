extends Control

var player_near_base: bool = false

var shop_items: Dictionary = {
	"Drill1": {"price": 250, "level": 1, "callback": func(): PlayerState.drill_power = max(PlayerState.drill_power, 1)},
	"Drill2": {"price": 1000, "level": 2, "callback": func(): PlayerState.drill_power = max(PlayerState.drill_power, 2)},
	"Drill3": {"price": 2000, "level": 3, "callback": func(): PlayerState.drill_power = max(PlayerState.drill_power, 3)},
	"Drill4": {"price": 5000, "level": 4, "callback": func(): PlayerState.drill_power = max(PlayerState.drill_power, 4)},
	"Bomb5x": {"price": 200, "callback": func(): PlayerState.bombs += 5},
	"Radar5x": {"price": 250, "callback": func(): PlayerState.radars += 5}
}

func _ready() -> void:
	visible = false # Hide by default
	for child in get_tree().get_nodes_in_group("ui_buttons"):
		if child is Button:
			child.pressed.connect(button_handler.bind(child))
	
	var quick_sell = get_node_or_null("Body/QuickSell")
	if quick_sell:
		quick_sell.pressed.connect(_on_quick_sell_pressed)

func _process(_delta: float) -> void:
	if visible:
		_update_ui()

func _update_ui() -> void:
	for item_id in shop_items.keys():
		var button = find_child(item_id, true, false)
		if button is Button:
			var item = shop_items[item_id]
			if item.has("level"):
				if PlayerState.drill_power >= item["level"]:
					button.text = "SOLD OUT"
					button.disabled = true
				else:
					button.disabled = PlayerState.money < item["price"]
			else:
				button.disabled = PlayerState.money < item["price"]

func button_handler(button: Button):
	var item_id = button.name
	if shop_items.has(item_id):
		var item = shop_items[item_id]
		if PlayerState.money >= item["price"]:
			PlayerState.money -= item["price"]
			item["callback"].call()
			_update_ui()

func _on_quick_sell_pressed():
	PlayerState.sell_all_ores()
	_update_ui()

# Signals were placed in the editor manually, not added by script.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		visible = false
