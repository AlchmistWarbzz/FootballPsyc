extends Node


var trial_length : int

var main_level : Level = null

var task_to_load : int = 0

var keyboard: bool = false

var subject_name : String = "Subject"

const SST_TASK_MANAGER = preload("res://SubScenes/SST_Task_Manager.tscn")
const SHIFTING_TASK_MANAGER = preload("res://SubScenes/Shifting_Task_Manager.tscn")
const BDS_TASK_MANAGER = preload("res://SubScenes/BDS_Task_Manager.tscn")

signal play_button_pressed
signal left_trigger
signal right_trigger
signal current_target

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func set_task_to_load(task : int) -> void:
	task_to_load = task
	
	set_level_task_scene()


func set_level_task_scene() -> void:
	match task_to_load:
		1:
			main_level.task_scene = SST_TASK_MANAGER
		2:
			main_level.task_scene = SHIFTING_TASK_MANAGER
		3:
			main_level.task_scene = BDS_TASK_MANAGER
