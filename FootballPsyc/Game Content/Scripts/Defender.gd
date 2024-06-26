extends CharacterBody3D


const SPEED = 6.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var moveTriggerFlag = false;

func _ready():
	var task_manager_node
	
	var placeholder_node = get_parent()
	if placeholder_node != null:
		task_manager_node = placeholder_node.get_parent()
	
	if task_manager_node != null:
		if task_manager_node.name == "SST_Task_Manager":
			task_manager_node.stop_signal.connect(_on_task_manager_stop_signal)

#func _on_task_manager_trial_started(is_stop_trial: bool):
	#if is_stop_trial:
		#moveTriggerFlag = true

func _on_task_manager_stop_signal():
	moveTriggerFlag = true
	
	# change to run animation
	#$Character/AnimationPlayer.set_current_animation("RunCycle")
	#$Character/AnimationPlayer.play("RunCycle")
	$Character/AnimationTree.set("parameters/Idle&Jog/blend_position", 1)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# manual keypress sequencing
	#if Input.is_action_just_pressed("s"):
		#moveTriggerFlag = true
	
	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = get_global_transform().basis.z.normalized()
	if moveTriggerFlag:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	if not is_on_floor_only():
		velocity.x = 0
		velocity.z = 0


