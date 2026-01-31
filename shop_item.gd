extends PanelContainer

@export var mask_type := 0
@export var mask_texture: Texture2D

@onready var texture_rect: TextureRect = $MarginContainer/VBoxContainer/TextureRect
@onready var price_label: Label = $MarginContainer/VBoxContainer/PriceLabel
@onready var buy_button: Button = $MarginContainer/VBoxContainer/BuyButton

var price := 10

func _ready() -> void:
	if mask_texture:
		texture_rect.texture = mask_texture
	
	price = GameManager.shop_prices.get(mask_type, 10)
	price_label.text = "$" + str(price)
	
	buy_button.pressed.connect(_on_buy_pressed)
	GameManager.money_changed.connect(_on_money_changed)
	update_button_state()

func _on_buy_pressed() -> void:
	if GameManager.buy_mask(mask_type):
		print("Purchased mask type ", mask_type)
		# Visual feedback
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	else:
		# Not enough money feedback
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.RED, 0.1)
		tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _on_money_changed(_new_amount: int) -> void:
	update_button_state()

func update_button_state() -> void:
	buy_button.disabled = GameManager.money < price
