extends Node

var trial_length : int
var main_scene : Node3D = null
var loaded_level : Level = null
var task_to_load_UI : int = 0
var keyboard: bool = false

var subject_name : String = "Subject"

signal play_button_pressed


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func load_task(task_to_load : int) -> void:
	task_to_load_UI = task_to_load
	#print(str(task_to_load_UI) + " from LevelManager.gd")
	
	main_scene.add_child(loaded_level)
	
	match task_to_load:
		1:
			loaded_level.task_to_load = loaded_level.SST_TASK_MANAGER
		2:
			loaded_level.task_to_load = loaded_level.SHIFTING_TASK_MANAGER
		3:
			loaded_level.task_to_load = loaded_level.BDS_TASK_MANAGER

