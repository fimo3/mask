extends CanvasLayer

@onready var slots: Array = [
	$Panel/MarginContainer/VBoxContainer/GridContainer/Slot0,
	$Panel/MarginContainer/VBoxContainer/GridContainer/Slot1,
	$Panel/MarginContainer/VBoxContainer/GridContainer/Slot2,
	$Panel/MarginContainer/VBoxContainer/GridContainer/Slot3
]

func _ready() -> void:
	GameManager.inventory_changed.connect(refresh_inventory)
	refresh_inventory()

func refresh_inventory() -> void:
	for slot in slots:
		if slot.has_method("update_display"):
			slot.update_display()

func show_inventory() -> void:
	refresh_inventory()
