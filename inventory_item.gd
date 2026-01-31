extends Panel

@export var mask_type := 0
@export var mask_icon: Texture2D

@onready var icon: Sprite2D = $Sprite2D
@onready var count_label: Label = $CountLabel
@onready var button: Button = $Button

var is_dragging := false

func _ready() -> void:
	# Ensure the panel can detect mouse events
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Make sure button is transparent and covers the whole panel
	if button:
		button.self_modulate = Color(1, 1, 1, 0)
		button.mouse_filter = Control.MOUSE_FILTER_PASS
	
	await get_tree().process_frame
	
	if icon and mask_icon:
		icon.texture = mask_icon
		icon.centered = true
		icon.position = size / 2  # Center the icon
	
	if GameManager.has_signal("inventory_changed"):
		GameManager.inventory_changed.connect(update_display)
	
	update_display()
	
	print("Inventory slot ", mask_type, " ready. Size: ", size)

func update_display() -> void:
	if not is_inside_tree() or not count_label:
		return
	
	var count = GameManager.get_mask_count(mask_type)
	count_label.text = "x" + str(count)
	
	if count <= 0:
		modulate = Color(0.5, 0.5, 0.5, 0.7)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		modulate = Color.WHITE
		mouse_filter = Control.MOUSE_FILTER_STOP
	
	print("Slot ", mask_type, " count updated to: ", count)

func _get_drag_data(_at_position: Vector2):
	var count = GameManager.get_mask_count(mask_type)
	
	print("_get_drag_data called for mask type ", mask_type, " with count ", count)
	
	if count <= 0:
		print("No masks available to drag")
		return null
	
	is_dragging = true
	
	# Create drag preview
	var preview = TextureRect.new()
	preview.texture = mask_icon
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(64, 64)
	preview.size = Vector2(64, 64)
	preview.modulate = Color(1, 1, 1, 0.7)
	
	# Center the preview under the mouse
	var container = Control.new()
	container.add_child(preview)
	preview.position = -Vector2(32, 32) 
	
	set_drag_preview(container)
	
	print("Drag started with mask type: ", mask_type)
	
	return {"mask_type": mask_type, "source": "inventory"}

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		is_dragging = false
		print("Drag ended. Success: ", get_viewport().gui_is_drag_successful())
		
		# Don't remove from inventory here - let the drop target handle it
		# The spawner will call GameManager.remove_mask_from_inventory when the drop is successful

func _can_drop_data(_at_position: Vector2, _data) -> bool:
	# Inventory slots don't accept drops
	return false
