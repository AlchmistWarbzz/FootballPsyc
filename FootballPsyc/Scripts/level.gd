extends Node


class_name Level

var task_scene
var instance
@onready var football_kick_sfx: AudioStreamPlayer = $Football_Kick_SFX

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#await get_tree().create_timer(10.0).timeout
	
	# WARNING only works if exactly 1 level exists
	LevelManager.main_level = self
	
	LevelManager.play_button_pressed.connect(_on_play_button_pressed)
	
	LevelManager.leave_trial.connect(_leave_trial)
	
	AudioManager.football_kick.connect(_on_football_kick)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_play_button_pressed() -> void:
	# task manager creation
	instance = task_scene.instantiate()
	add_child(instance)
	

func _on_football_kick() -> void:
	football_kick_sfx.play()

func _leave_trial():
	instance.queue_free()
