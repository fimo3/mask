extends Node2D

@export var person_scene: PackedScene = preload("res://person.tscn")

@onready var start_point: Marker2D = $SpawnPoint/Start
@onready var center_point: Marker2D = $SpawnPoint/Center
@onready var end_point: Marker2D = $SpawnPoint/End

var people_queue: Array[Node2D] = []
var max_people := 3
var person
var is_moving = false
func spawn_person_at(pos):
	person = person_scene.instantiate()
	person.position = pos
	add_child(person)
	people_queue.append(person)

func _ready():
	randomize()

	spawn_person_at(center_point.global_position)

	spawn_person_at(start_point.global_position)
	$Shop.layer = 10
func _on_next_button_pressed():
	if is_moving:
		return

	is_moving = true

	advance_queue()
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
