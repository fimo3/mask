extends Control

@onready var money_label: Label = $Money
@onready var shop_button: Button = $ShopButton

signal inventory_pressed
signal shop_pressed

func _ready() -> void:
	GameManager.money_changed.connect(_on_money_changed)
	update_money_display(GameManager.money)
	
#	inventory_button.pressed.connect(func(): inventory_pressed.emit())
	#shop_button.pressed.connect(func(): shop_pressed.emit())

func _on_money_changed(new_amount: int) -> void:
	update_money_display(new_amount)

func update_money_display(amount: int) -> void:
	money_label.text = "$" + str(amount)
