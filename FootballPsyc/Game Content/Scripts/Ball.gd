extends RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var task_manager_node
	
	#var placeholder_node = get_parent()
	#if placeholder_node != null:
		#task_manager_node = placeholder_node.get_parent()
	#task_manager_node = $SST_Task_Manager
	task_manager_node = get_parent().get_parent().get_parent()
	
	if task_manager_node != null:
		task_manager_node.ball_kicked.connect(_on_task_manager_ball_kicked)
	
	body_entered.connect(_on_collision)
	
	# ball feeder launch
	apply_central_impulse(get_global_transform().basis.z * 18)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_collision(body: Node):
	if body.name == "Teammate":
		set_linear_velocity(Vector3.ZERO)
		set_angular_velocity(Vector3.ZERO)
		print("ball hit Teammate. kill velocity")


func _on_task_manager_ball_kicked(target: Vector3, impulse_magnitude: float):
	kick(target, impulse_magnitude)


func kick(target: Vector3, impulse_magnitude: float) -> void:
	set_linear_velocity(Vector3.ZERO)
	set_angular_velocity(Vector3.ZERO)
	look_at(target)
	
	apply_central_impulse(get_global_transform().basis.z * -1 * impulse_magnitude)
	
	AudioManager.football_kick_sfx.set_pitch_scale(1.0 + (randf() / 20.0))
	AudioManager.football_kick_sfx.play()
