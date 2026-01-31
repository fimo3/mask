extends CharacterBody2D

@export var mask_type := 0
@onready var placeholder: Area2D = $"../../Placeholder"

var dragging = false
var offset := Vector2.ZERO
var start_pos: Vector2
var is_placed = false
var is_from_inventory = false

func _ready() -> void:
	start_pos = global_position
	placeholder.body_entered.connect(_on_placeholder_body_entered)
	placeholder.body_exited.connect(_on_placeholder_body_exited)

func setup_from_inventory(type: int) -> void:
	mask_type = type
	is_from_inventory = true
	print("Mask setup from inventory with type: ", type)

func _on_placeholder_body_entered(body: Node2D) -> void:
	if body == self and dragging:
		return
	if body == self:
		global_position = placeholder.global_position - Vector2(64, 64)
		is_placed = true
		print("Snapped to placeholder")

func _on_placeholder_body_exited(body: Node2D) -> void:
	if body == self:
		is_placed = false
		print("Left placeholder")

func _physics_process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - offset

func _on_button_button_down() -> void:
	dragging = true
	is_placed = false
	offset = get_global_mouse_position() - global_position

func _on_button_button_up() -> void:
	dragging = false
	
	var overlapping_bodies = placeholder.get_overlapping_bodies()
	if self in overlapping_bodies:
		global_position = placeholder.global_position - Vector2(64, 64)
		is_placed = true
		print("Placed in placeholder")
	else:
		if is_from_inventory:
			# Return to inventory instead of start position
			queue_free()
		else:
			global_position = start_pos

func get_mask_type() -> int:
	return mask_type
