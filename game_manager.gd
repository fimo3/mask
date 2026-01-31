extends Node

signal money_changed(new_amount: int)
signal inventory_changed

var money := 50  # Starting money
var mask_price := 15  # Selling price
var wrong_mask_penalty := 5

# Inventory: mask_type -> quantity
var inventory: Dictionary = {
	0: 2,  # Start with 2 masks of type 0
	1: 0,
	2: 0,
	3: 0
}

# Shop prices for buying masks
var shop_prices: Dictionary = {
	0: 10,
	1: 12,
	2: 15,
	3: 20
}

func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)

func remove_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		return true
	return false

func buy_mask(mask_type: int) -> bool:
	var price = shop_prices.get(mask_type, 10)
	if remove_money(price):
		add_mask_to_inventory(mask_type)
		return true
	return false

func add_mask_to_inventory(mask_type: int) -> void:
	if not inventory.has(mask_type):
		inventory[mask_type] = 0
	inventory[mask_type] += 1
	inventory_changed.emit()

func remove_mask_from_inventory(mask_type: int) -> bool:
	if inventory.get(mask_type, 0) > 0:
		inventory[mask_type] -= 1
		inventory_changed.emit()
		return true
	return false

func get_mask_count(mask_type: int) -> int:
	return inventory.get(mask_type, 0)

func has_mask(mask_type: int) -> bool:
	return get_mask_count(mask_type) > 0

# Alias method for remove_mask that inventory_item calls
func remove_mask(mask_type: int, amount: int = 1) -> bool:
	if inventory.get(mask_type, 0) >= amount:
		inventory[mask_type] -= amount
		inventory_changed.emit()
		return true
	return false
