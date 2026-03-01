extends Node

var drill_power: int = 1
var bombs: int = 3
var money: int = 0
var inventory: Dictionary = {}
var mined_tiles: Dictionary = {}

func reset() -> void:
	drill_power = 1
	bombs = 3
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
