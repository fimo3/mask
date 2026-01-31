extends Panel

signal slot_dragged(mask_type: int, slot_position: Vector2)

@export var mask_type := 0
@export var mask_icon: Texture2D

@onready var icon: Sprite2D = $Sprite2D
@onready var count_label: Label = $CountLabel

var is_dragging := false

func _ready() -> void:
	# Ensure the panel can detect the mouse
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	await get_tree().process_frame
	
	if icon and mask_icon:
		icon.texture = mask_icon
	
	if GameManager.has_signal("inventory_changed"):
		GameManager.inventory_changed.connect(update_display)
	
	update_display()

func update_display() -> void:
	if not is_inside_tree() or not count_label:
		return
	
	var count = GameManager.get_mask_count(mask_type)
	count_label.text = "x" + str(count)
	
	if count <= 0:
		modulate = Color(0.5, 0.5, 0.5, 0.7)
	else:
		modulate = Color.WHITE

func _get_drag_data(_at_position: Vector2):
	var count = GameManager.get_mask_count(mask_type)
	
	if count <= 0:
		return null
	
	is_dragging = true
	
	# Create drag preview
	var preview = TextureRect.new()
	preview.texture = mask_icon
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(64, 64)
	preview.modulate = Color(1, 1, 1, 0.7)
	
	# Center the preview under the mouse
	var container = Control.new()
	container.add_child(preview)
	preview.position = -Vector2(32, 32) 
	
	set_drag_preview(container)
	
	return {"mask_type": mask_type, "source": "inventory"}

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		is_dragging = false
		if get_viewport().gui_is_drag_successful():
			GameManager.remove_mask(mask_type, 1)
