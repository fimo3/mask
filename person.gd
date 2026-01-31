extends Node2D

@export var face_sprites: Array[Texture2D]
@export var min_problem_id := 0
@export var max_problem_id := 0

var problem_id: int
var is_served := false

@onready var sprite: Sprite2D = $Sprite

func _ready():
	assign_random_problem()

func assign_random_problem():
	if face_sprites.is_empty():
		push_error("Face sprites array is empty!")
		return
	
	if max_problem_id == 0:
		max_problem_id = face_sprites.size() - 1
	
	problem_id = randi_range(min_problem_id, max_problem_id)
	sprite.texture = face_sprites[problem_id]

func get_problem_id() -> int:
	return problem_id

func set_served(value: bool) -> void:
	is_served = value

func move_to(target: Vector2, duration := 0.5):
	var tween = create_tween()
	tween.tween_property(self, "position", target, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
