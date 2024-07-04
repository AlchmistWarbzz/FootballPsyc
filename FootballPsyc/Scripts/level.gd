extends Node

class_name Level

const BDS_TASK_MANAGER = preload("res://SubScenes/BDS_Task_Manager.tscn")
const SHIFTING_TASK_MANAGER = preload("res://SubScenes/Shifting_Task_Manager.tscn")
const SST_TASK_MANAGER = preload("res://SubScenes/SST_Task_Manager.tscn")

var task_to_load


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#await get_tree().create_timer(10.0).timeout
	
	LevelManager.play_button_pressed.connect(_on_play_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_play_button_pressed() -> void:
	# task manager creation
	var instance = task_to_load.instantiate()
	add_child(instance)

