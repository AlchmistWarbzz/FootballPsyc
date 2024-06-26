extends Node3D

const RED_BALL = preload("res://SubScenes/RedBall.tscn")
const BLUE_BALL = preload("res://SubScenes/BlueBall.tscn")

@export var _left_feeder: bool

var _ball

# Called when the node enters the scene tree for the first time.
func _ready():
	var task_manager_node
	
	var placeholder_node = get_parent()
	if placeholder_node != null:
		task_manager_node = placeholder_node.get_parent()
	
	if task_manager_node != null:
		task_manager_node.trial_started.connect(_on_task_manager_trial_started)
	
	if task_manager_node != null:
		task_manager_node.trial_ended.connect(_on_task_manager_trial_ended)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# manual keypress sequencing
	#if Input.is_action_just_pressed("g") or Input.is_action_just_pressed("s"):
		#instantiate_ball()
	pass

func _on_task_manager_trial_started(is_blue_ball: bool, is_left_feeder: bool):
	if _left_feeder == is_left_feeder:
		instantiate_ball(is_blue_ball)
		AudioManager.ball_feeder_launch_sfx.set_pitch_scale(1.0 - (randf() / 10.0))
		AudioManager.ball_feeder_launch_sfx.play()

func _on_task_manager_trial_ended():
	if _ball != null:
		_ball.free()

func instantiate_ball(is_blue_ball: bool):
	#var instance
	if is_blue_ball:
		_ball = BLUE_BALL.instantiate()
	else:
		_ball = RED_BALL.instantiate()
	_ball.set_transform($BallSpawnPoint.transform)
	add_child(_ball)
	return _ball
