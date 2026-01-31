extends Control

@onready var item_container: HBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/ItemContainer
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/CloseButton
@onready var money_label: Label = $Panel/MarginContainer/VBoxContainer/MoneyLabel

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	GameManager.money_changed.connect(_on_money_changed)
	update_money_display(GameManager.money)

func _on_money_changed(new_amount: int) -> void:
	update_money_display(new_amount)

func update_money_display(amount: int) -> void:
	money_label.text = "Money: $" + str(amount)

func _on_close_pressed() -> void:
	hide()

func show_shop() -> void:
	show()
	update_money_display(GameManager.money)
