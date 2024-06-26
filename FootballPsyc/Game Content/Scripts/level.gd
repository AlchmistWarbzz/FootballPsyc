extends Node

class_name Level

@export var level_id : int
var level_data : LevelData



const BDS_TASK_MANAGER = preload("res://SubScenes/BDS_Task_Manager.tscn")
const SHIFTING_TASK_MANAGER = preload("res://SubScenes/Shifting_Task_Manager.tscn")
const SST_TASK_MANAGER = preload("res://SubScenes/SST_Task_Manager.tscn")

var task_to_load

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_data = LevelManager.get_level_data_by_id(level_id)
	
	#await get_tree().create_timer(10.0).timeout # TODO replace: wait for play button
	
	LevelManager.play_button_pressed.connect(_on_play_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_play_button_pressed() -> void:
	# task manager creation
	var instance = task_to_load.instantiate()
	add_child(instance)
