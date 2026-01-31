extends Control

signal mask_dropped(mask_type: int)

# Visual feedback
var is_hovering := false
var placeholder_visual: ColorRect

func _ready() -> void:
	# CRITICAL: Must be able to receive mouse events
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Set a minimum size so it's actually hittable
	custom_minimum_size = Vector2(150, 150)
	
	# Create visual feedback
	placeholder_visual = ColorRect.new()
	placeholder_visual.color = Color(0.3, 0.3, 0.3, 0.3)
	placeholder_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(placeholder_visual)
	placeholder_visual.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	print("Drop zone ready at position: ", global_position)
	print("Drop zone size: ", size)
	print("Drop zone mouse_filter: ", mouse_filter)

func _can_drop_data(at_position: Vector2, data) -> bool:
	print("=== CAN DROP? ===")
	print("Position: ", at_position)
	print("Data type: ", typeof(data))
	print("Data: ", data)
	
	# Accept drops from inventory
	if typeof(data) == TYPE_DICTIONARY:
		print("Data keys: ", data.keys())
		if data.has("source") and data.source == "inventory":
			is_hovering = true
			if placeholder_visual:
				placeholder_visual.color = Color(1, 1, 0, 0.5)  # Yellow highlight
			print("✓ ACCEPTING DROP")
			return true
	
	print("✗ REJECTING drop")
	return false

func _drop_data(at_position: Vector2, data) -> void:
	print("=== DROP RECEIVED ===")
	print("Position: ", at_position)
	print("Data: ", data)
	
	is_hovering = false
	if placeholder_visual:
		placeholder_visual.color = Color(0.3, 0.3, 0.3, 0.3)
	
	if data.has("mask_type"):
		print("✓ Emitting mask_dropped(", data.mask_type, ")")
		mask_dropped.emit(data.mask_type)
	else:
		print("✗ ERROR: No mask_type in data!")

func _process(_delta: float) -> void:
	# Reset hover state
	if not is_hovering and placeholder_visual:
		placeholder_visual.color = Color(0.3, 0.3, 0.3, 0.3)
