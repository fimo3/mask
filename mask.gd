extends CharacterBody2D

@onready var window: Area2D = $"../window"

var dragging = false
var offset := Vector2.ZERO
var start_pos: Vector2

func _ready() -> void:
	start_pos = global_position

func _physics_process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - offset

func _on_button_button_down() -> void:
	dragging = true
	offset = get_global_mouse_position() - global_position

func _on_button_button_up() -> void:
	dragging = false
	#напиши позициите на прозореца и му сложи Area2D
	if position.x > -36 and position.x < 164:
		if position.y > -75 and position.y < 75:
			position = window.position
		else: global_position = start_pos
	else: global_position = start_pos
