extends Node

var drill_power: int = 1
var bombs: int = 3
var money: int = 0
var inventory: Dictionary = {}

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
