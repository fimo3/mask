extends Area2D

signal mask_dropped(mask_type: int)

func _can_drop_data(_at_position: Vector2, data) -> bool:
	if typeof(data) == TYPE_DICTIONARY and data.has("source"):
		return data.source == "inventory"
	return false

func _drop_data(_at_position: Vector2, data) -> void:
	if data.has("mask_type"):
		mask_dropped.emit(data.mask_type)
