extends Node

var drill_power: int = 1
var bombs: int = 3
var radars: int = 3
var money: int = 0
var inventory: Dictionary = {}
var mined_tiles: Dictionary = {}

var item_prices: Dictionary = {
	"sand": 0,
	"soft_rock": 0,
	"hard_rock": 0,
	"ultra_hard_rock": 10,
	"soft_copper": 5,
	"hard_copper": 10,
	"soft_iron": 20,
	"hard_iron": 25,
	"soft_gold": 35,
	"hard_gold": 50
}

func sell_all_ores() -> void:
	var total_sale = 0
	for item in inventory.keys():
		if item_prices.has(item):
			total_sale += inventory[item] * item_prices[item]
	
	money += total_sale
	inventory.clear()

func reset() -> void:
	drill_power = 1
	bombs = 3
	radars = 3
	money = 0
	inventory = {}

func add_item(item_name: String, amount: int) -> void:
	if inventory.has(item_name):
		inventory[item_name] += amount
	else:
		inventory[item_name] = amount

func add_mined_tile(scene_name: String, tile_pos: Vector2i) -> void:
	if not mined_tiles.has(scene_name):
		mined_tiles[scene_name] = []
	if not tile_pos in mined_tiles[scene_name]:
		mined_tiles[scene_name].append(tile_pos)

func get_mined_tiles(scene_name: String) -> Array:
	return mined_tiles.get(scene_name, [])
