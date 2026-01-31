extends Node2D

@export var person_scene: PackedScene = preload("res://person.tscn")
@export var mask_scene: PackedScene
@onready var placeholder: Area2D = $"../Placeholder"
@onready var start_point: Marker2D = $SpawnPoint/Start
@onready var center_point: Marker2D = $SpawnPoint/Center
@onready var end_point: Marker2D = $SpawnPoint/End
@onready var next_button: Button = $"../UI/Next"

var people_queue: Array[Node2D] = []
var max_people := 3
var current_mask: Node2D = null
var is_moving = false

var inventory_ui: CanvasLayer
var shop_ui: CanvasLayer
var mask_drop_zone: Control  # Reference to drop zone

func _ready():
	randomize()
	spawn_person_at(center_point.global_position)
	spawn_person_at(start_point.global_position)
	
	if next_button:
		next_button.pressed.connect(_on_next_button_pressed)
	if placeholder:
		placeholder.mask_dropped.connect(_on_mask_dropped)

func setup_ui_references(inv: CanvasLayer, shp: CanvasLayer, drop_zone: Control) -> void:
	inventory_ui = inv
	shop_ui = shp
	mask_drop_zone = drop_zone
	
	if mask_drop_zone:
		mask_drop_zone.mask_dropped.connect(_on_mask_dropped)

func _on_mask_dropped(mask_type: int) -> void:
	# Remove existing mask
	if current_mask:
		current_mask.queue_free()
	
	# Check and remove from inventory
	if GameManager.remove_mask_from_inventory(mask_type):
		# Spawn mask
		current_mask = mask_scene.instantiate()
		get_parent().add_child(current_mask)
		
		# Position at drop zone
		if mask_drop_zone:
			current_mask.global_position = mask_drop_zone.global_position + Vector2(32, 32)
		else:
			current_mask.global_position = Vector2(800, 300)
		
		current_mask.mask_type = mask_type
		print("Placed mask type ", mask_type, " from inventory")
		
		# Close inventory after successful drop
		if inventory_ui:
			inventory_ui.hide()

func spawn_person_at(pos):
	var person = person_scene.instantiate()
	person.position = pos
	add_child(person)
	people_queue.append(person)

func _on_next_button_pressed():
	if is_moving:
		return
	
	if people_queue.size() > 0:
		check_transaction(people_queue[0])
	
	is_moving = true
	advance_queue()

func check_transaction(current_person: Node2D) -> void:
	if current_person.is_served:
		return
	
	if current_mask == null:
		print("No mask placed")
		return
	
	var person_problem = current_person.get_problem_id()
	var placed_mask_type = current_mask.mask_type
	
	if person_problem == placed_mask_type:
		GameManager.add_money(GameManager.mask_price)
		current_person.set_served(true)
		print("✓ Correct! +$", GameManager.mask_price)
		
		# Visual feedback
		flash_green()
	else:
		GameManager.remove_money(GameManager.wrong_mask_penalty)
		current_person.set_served(true)
		print("✗ Wrong! -$", GameManager.wrong_mask_penalty)
		
		# Visual feedback
		flash_red()
	
	# Remove used mask
	if current_mask:
		current_mask.queue_free()
		current_mask = null

func flash_green():
	if mask_drop_zone and mask_drop_zone.has_node("PlaceholderVisual"):
		var visual = mask_drop_zone.get_node("PlaceholderVisual")
		var tween = create_tween()
		tween.tween_property(visual, "color", Color.GREEN, 0.2)
		tween.tween_property(visual, "color", Color(0.3, 0.3, 0.3, 0.3), 0.3)

func flash_red():
	if mask_drop_zone and mask_drop_zone.has_node("PlaceholderVisual"):
		var visual = mask_drop_zone.get_node("PlaceholderVisual")
		var tween = create_tween()
		tween.tween_property(visual, "color", Color.RED, 0.2)
		tween.tween_property(visual, "color", Color(0.3, 0.3, 0.3, 0.3), 0.3)

func advance_queue():
	if people_queue.size() > 0:
		var leaving = people_queue.pop_front()
		leaving.move_to(end_point.global_position)
		await get_tree().create_timer(0.6).timeout
		leaving.queue_free()
	
	if people_queue.size() > 0:
		people_queue[0].move_to(center_point.global_position)
	
	if people_queue.size() < max_people - 1:
		await get_tree().create_timer(0.3).timeout
		spawn_person_at(start_point.global_position)
	
	await get_tree().create_timer(0.5).timeout
	is_moving = false
