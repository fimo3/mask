extends Node2D

@export var person_scene: PackedScene = preload("res://person.tscn")
@export var mask_scene: PackedScene = preload("res://mask.tscn")
@onready var drop_zone: Control = $UI/DropZone
@onready var start_point: Marker2D = $SpawnPoint/Start
@onready var center_point: Marker2D = $SpawnPoint/Center
@onready var end_point: Marker2D = $SpawnPoint/End
@onready var next_button: Button = $UI/Next

var people_queue: Array[Node2D] = []
var max_people := 3
var current_mask: Node2D = null
var is_moving = false

func _ready():
	randomize()
	spawn_person_at(center_point.global_position)
	spawn_person_at(start_point.global_position)
	
	if next_button:
		next_button.pressed.connect(_on_next_button_pressed)
	
	# Connect to the Control-based drop zone instead of Area2D
	if drop_zone:
		drop_zone.mask_dropped.connect(_on_mask_dropped)
		print("✓ Connected to drop zone")
	else:
		print("✗ ERROR: Drop zone not found!")

func _on_mask_dropped(mask_type: int) -> void:
	print("=== MASK DROPPED HANDLER ===")
	print("Mask type: ", mask_type)
	
	# Remove existing mask if any
	if current_mask:
		print("Removing old mask")
		current_mask.queue_free()
		current_mask = null
	
	# Check if we have this mask in inventory
	if not GameManager.has_mask(mask_type):
		print("✗ No mask of type ", mask_type, " in inventory!")
		return
	
	print("Inventory check passed, count: ", GameManager.get_mask_count(mask_type))
	
	# Remove from inventory
	if GameManager.remove_mask_from_inventory(mask_type):
		print("✓ Removed from inventory")
		
		# Spawn new mask at placeholder (the Area2D visual position)
		current_mask = mask_scene.instantiate()
		add_child(current_mask)
		
		# Position at the placeholder Area2D for visual consistency
		
		
		# Set mask properties
		current_mask.mask_type = mask_type
		current_mask.is_from_inventory = true
		current_mask.is_placed = true
		
		# Load and set the appropriate texture
		var texture: Texture2D
		match mask_type:
			0:
				texture = load("res://Assets/icon.svg")
			1:
				texture = load("res://Assets/Mouth.png")
			2:
				texture = load("res://Assets/Ears.png")
			3:
				texture = load("res://Assets/Eyes.png")
			_:
				texture = load("res://Assets/icon.svg")
		
		# Set the texture using the mask's method
		if current_mask.has_method("set_mask_texture"):
			current_mask.set_mask_texture(texture)
		elif current_mask.has_node("Sprite"):
			current_mask.get_node("Sprite").texture = texture
			print("✓ Set sprite texture directly for type ", mask_type)
		
		print("✓ Mask spawned successfully at ", current_mask.global_position)
	else:
		print("✗ Failed to remove mask from inventory")

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
		print("No mask placed - penalty!")
		GameManager.remove_money(GameManager.wrong_mask_penalty)
		current_person.set_served(true)
		flash_red()
		return
	
	var person_problem = current_person.get_problem_id()
	var placed_mask_type = current_mask.mask_type
	
	if person_problem == placed_mask_type:
		GameManager.add_money(GameManager.mask_price)
		current_person.set_served(true)
		print("✓ Correct! +$", GameManager.mask_price)
		flash_green()
	else:
		GameManager.remove_money(GameManager.wrong_mask_penalty)
		current_person.set_served(true)
		print("✗ Wrong! Expected ", person_problem, " got ", placed_mask_type, " -$", GameManager.wrong_mask_penalty)
		flash_red()
	
	# Remove used mask
	if current_mask:
		current_mask.queue_free()
		current_mask = null

func flash_green():
	if drop_zone:
		var tween = create_tween()
		tween.tween_property(drop_zone, "modulate", Color.GREEN, 0.2)
		tween.tween_property(drop_zone, "modulate", Color.WHITE, 0.3)

func flash_red():
	if drop_zone:
		var tween = create_tween()
		tween.tween_property(drop_zone, "modulate", Color.RED, 0.2)
		tween.tween_property(drop_zone, "modulate", Color.WHITE, 0.3)

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
