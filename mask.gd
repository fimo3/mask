extends CharacterBody2D

@export var mask_type := 0

var dragging = false
var offset := Vector2.ZERO
var start_pos: Vector2
var is_placed = false
var is_from_inventory = false

func _ready() -> void:
	start_pos = global_position
	
	# Connect button signals if they exist
	if has_node("Button"):
		var button = get_node("Button")
		if not button.button_down.is_connected(_on_button_button_down):
			button.button_down.connect(_on_button_button_down)
		if not button.button_up.is_connected(_on_button_button_up):
			button.button_up.connect(_on_button_button_up)
	
	print("Mask ready. Type: ", mask_type, " From inventory: ", is_from_inventory, " at ", global_position)

func setup_from_inventory(type: int) -> void:
	mask_type = type
	is_from_inventory = true
	is_placed = true  # Consider it placed when spawned from inventory
	print("Mask setup from inventory with type: ", type)

func _physics_process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - offset

func _on_button_button_down() -> void:
	dragging = true
	offset = get_global_mouse_position() - global_position
	print("Mask drag started (type ", mask_type, ")")

func _on_button_button_up() -> void:
	dragging = false
	print("Mask drag ended at ", global_position)
	
	# Optional: If you want the mask to snap back if moved away from drop zone
	# But for now, just let it stay where the user drops it

func get_mask_type() -> int:
	return mask_type

func set_mask_texture(texture: Texture2D) -> void:
	if has_node("Sprite"):
		get_node("Sprite").texture = texture
		print("✓ Set mask texture for type ", mask_type)
	else:
		push_error("Mask has no Sprite node!")
