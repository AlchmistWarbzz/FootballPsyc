extends Node3D

# spawnables
const BALL_FEEDER_SCENE = preload("res://SubScenes/Ball_Feeder.tscn")
const FIXATION_CONE = preload("res://SubScenes/Fixation_Cone.tscn")
const M_TEMP_GOAL = preload("res://Materials/M_TempGoal.tres")
const BLUE_BALL = preload("res://SubScenes/BlueBall.tscn")

# time
@export var ticks_between_trials_msec: int = 3000
@export var ready_ticks_msec: int = 250
@export var target_show_ticks_msec: int = 750
@export var trial_ticks_msec: int = 50000

@onready var ticks_msec_bookmark: int = 0

# blocks
enum block_type {TEST, PRACTICE}
## Array determines the order and type of blocks in the test.
@export var blocks: Array[block_type] = []
var blocks_index: int = 0

#@export var practice_block_span_max_digits: int = 5
#@export var test_block_span_max_digits: int = 9
@export var trials_per_practice_block: int = 3
@export var trials_per_test_block: int = 9

# counters
var trials_per_block: int = trials_per_practice_block
var block_counter: int = 0
var trial_counter: int = 0
var trials_passed: int = 0
var span_length: int = 3

# metrics
@onready var metrics_array = Array()
@onready var start_datetime = Time.get_datetime_dict_from_system()

# states
enum scene_state {WAIT, READY, SHOW_TARGET, TRIAL}
@onready var current_state = scene_state.WAIT

# signals
signal trial_started
signal ball_kicked
@export var ball_kick_magnitude : float = 15
@export var ball_kick_height_offset : float = 4

# flags
var is_trial_passed: bool = false

# spans
@onready var targets = [$"0/MeshInstance3D", $"1/MeshInstance3D"
		, $"2/MeshInstance3D", $"3/MeshInstance3D"
		, $"4/MeshInstance3D", $"5/MeshInstance3D"
		, $"6/MeshInstance3D"]
@onready var random_span = Array()
@onready var random_span_numbers = Array()
@onready var player_input_span = Array()

# span pointers
var current_target_show_index: int = -1
#var next_target_show_index: int = current_target_show_index + 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.ambience_sfx.play()
	
	reset_counters()
	
	scene_reset() # ensure scene and scene_state are in agreement


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("save_log"):
		#scene_trial_start(true)
		write_sst_raw_log(Time.get_datetime_dict_from_system())
		write_sst_summary_log(Time.get_datetime_dict_from_system())
	
	# tick-based scene sequencing
	match current_state:
		scene_state.WAIT:
			if (Time.get_ticks_msec() - ticks_msec_bookmark) > ticks_between_trials_msec:
				# wait time is up
				
				# check block finished
				
				#var block_finished_flag : bool = false
				#if blocks[blocks_index] == block_type.PRACTICE:
					#if span_length > practice_block_span_max_digits:
						#block_finished_flag = true
				#else:
					#if span_length > test_block_span_max_digits:
						#block_finished_flag = true
				
				if trial_counter >= trials_per_block:
					print("block " + str(blocks_index + 1) + " finished.")
					
					write_sst_raw_log(Time.get_datetime_dict_from_system())
					write_sst_summary_log(Time.get_datetime_dict_from_system())
					
					# check if all blocks in sequence done
					if blocks_index + 1 < blocks.size():
						# set up next block
						blocks_index += 1
						reset_counters()# reset counters now their data has been logged
						
						# TODO new block transition
						
						scene_reset()
					else:
						print("all blocks finished. returning to main menu.")
						get_tree().change_scene_to_file("res://Main.tscn")
				else:
					scene_ready()
		
		
		scene_state.READY:
			if (Time.get_ticks_msec() - ticks_msec_bookmark) > ready_ticks_msec:
				# ready time is up
				
				if current_target_show_index < span_length:
					scene_show_target()
				else:
					scene_trial_start()
		
		
		scene_state.SHOW_TARGET:
			if (Time.get_ticks_msec() - ticks_msec_bookmark) > target_show_ticks_msec:
				# show time is up
				scene_hide_target()
				scene_ready()
		
		
		scene_state.TRIAL:
			var required_input_span = random_span_numbers.duplicate()
			required_input_span.reverse() # ensure backward digits
			#print(required_input_span)
			
			if (Time.get_ticks_msec() - ticks_msec_bookmark) > trial_ticks_msec:
				# trial time is up
				
				if not is_trial_passed:
					#go_trial_failed.emit()
					print("trial_failed")
				
				append_new_metrics_entry(required_input_span, [])
				
				scene_reset()
			
			if Input.is_action_just_pressed("select"):
				var raycast_length = 1000
				var space_state = get_world_3d().get_direct_space_state()
				var mouse_position = get_viewport().get_mouse_position()
				var params = PhysicsRayQueryParameters3D.new()
				params.from = get_viewport().get_camera_3d().project_ray_origin(mouse_position)
				params.to = params.from + get_viewport().get_camera_3d().project_ray_normal(mouse_position) * raycast_length
				params.collision_mask = 2
				var result = space_state.intersect_ray(params)
				if result: #if mouse clicked target
					print("mouse ray hit target " + result.collider.name)
					player_input_span.append(result.collider.name)
					
					# destroy previous ball if found
					var old_ball = $Player/PlaceholderBall.get_child(0)
					if old_ball != null:
						old_ball.queue_free()
					
					# create new ball
					var instance
					instance = BLUE_BALL.instantiate()
					$Player/PlaceholderBall.add_child(instance)
					ball_kicked.emit(result.collider.get_global_position() + (Vector3.UP * ball_kick_height_offset)
					, ball_kick_magnitude)
				
				if player_input_span == required_input_span:
					# trial passed
					print("trial passed")
					is_trial_passed = true
					trials_passed += 1
					
					append_new_metrics_entry(required_input_span, player_input_span)
					
					span_length += 1
					print("span length increased to " + str(span_length))
					
					scene_reset()
				
				elif player_input_span.size() >= random_span.size():
					print("trial failed")
					
					append_new_metrics_entry(required_input_span, player_input_span)
					
					scene_reset()


func scene_reset():
	print("scene_reset")
	
	# reset span stuff
	current_target_show_index = -1
	player_input_span = Array()
	
	# calculate new span stuff
	var s = targets.duplicate()
	s.shuffle()
	random_span = s.slice(0, span_length, 1)
	
	# update vars
	random_span_numbers = Array()
	for n in random_span:
		var n_string = str(targets.find(n))
		random_span_numbers.append(StringName(n_string))
	
	# spawn fixation cone
	var new_fixation_cone = FIXATION_CONE.instantiate()
	$PlaceholderFixation.add_child(new_fixation_cone)
	
	current_state = scene_state.WAIT
	ticks_msec_bookmark = Time.get_ticks_msec()

func scene_ready():
	#print("scene_ready")
	
	current_target_show_index += 1
	
	current_state = scene_state.READY
	ticks_msec_bookmark = Time.get_ticks_msec()

func scene_show_target():
	#random_span[next_target_to_show_index].set_surface_override_material(0, M_TEMP_GOAL)
	random_span[current_target_show_index].set_surface_override_material(0, M_TEMP_GOAL)
	print("scene_show_target " + str(random_span_numbers[current_target_show_index]))
	
	current_state = scene_state.SHOW_TARGET
	ticks_msec_bookmark = Time.get_ticks_msec()

func scene_hide_target():
	random_span[current_target_show_index].set_surface_override_material(0, null)

func scene_trial_start():
	# update trial counters
	trial_counter += 1
	
	print("scene_trial_start " + str(trial_counter))
	
	# remove fixation cone
	if $PlaceholderFixation.get_child_count() != 0:
		$PlaceholderFixation/FixationCone.free()

	# set up flags
	is_trial_passed = false
	
	current_state = scene_state.TRIAL
	ticks_msec_bookmark = Time.get_ticks_msec()

func reset_counters():
	print("start TARGET DIGIT TEST block " + str(blocks_index + 1) + ". is_practice_block: " + str(blocks[blocks_index] == block_type.PRACTICE))
	
	if blocks[blocks_index] == block_type.PRACTICE:
		trials_per_block = trials_per_practice_block
	else:
		trials_per_block = trials_per_test_block
	block_counter = 0
	trial_counter = 0
	trials_passed = 0
	span_length = 3

func append_new_metrics_entry(required_input_array: Array, player_input_array: Array):
	metrics_array.append([block_counter, trial_counter, span_length, is_trial_passed, required_input_array, player_input_array])

func write_sst_raw_log(datetime_dict):
	# open/create file
	var practice_str: String = ""
	if blocks[blocks_index] == block_type.PRACTICE:
		practice_str = "practice_"
	
	var raw_log_file_path: String = LevelManager.subject_name + "_target_digit_" + practice_str + "{year}-{month}-{day}-{hour}-{minute}-{second}_raw.txt".format(datetime_dict) # TODO let user choose dir
	var raw_log_file = FileAccess.open(raw_log_file_path, FileAccess.WRITE)
	print("raw log file created at " + raw_log_file_path + " with error code " + str(FileAccess.get_open_error()))
	
	# format guide
	# block_counter: int, trial_counter: int, stimulus_left: bool, stop_trial: bool,
	# correct_response: bool, response_time: int (ms), stop_signal_delay: int (ms)
	if raw_log_file:
		# write date, time, subject, group, format guide
		raw_log_file.store_line("PsychologyFootball - Target Digit Test - Raw Data Log")
		raw_log_file.store_line("date: {day}-{month}-{year}".format(datetime_dict))
		raw_log_file.store_line("time: {hour}:{minute}:{second}".format(datetime_dict))
		raw_log_file.store_line("start date: {day}-{month}-{year}".format(start_datetime))
		raw_log_file.store_line("start time: {hour}:{minute}:{second}".format(start_datetime))
		raw_log_file.store_line("subject: " + LevelManager.subject_name) # TODO fill user-input subject and group
		raw_log_file.store_line("group: test")
		raw_log_file.store_string("\n-Format Guide-\n\nblock_counter, trial_counter, span_length, correct_response, [required_input_array], [player_input_array]")
		raw_log_file.store_string("\n\n-Raw Data-\n\n")
		
		for sub_array in metrics_array:
			#var line = "{0}, {1}, {2}, {3}, {4}, {5}, {6}"
			#raw_log_file.store_line(line.format(sub_array))
			for item in sub_array:
				if type_string(typeof(item)) == "TYPE_ARRAY":
					raw_log_file.store_string("[")
					for sequenceNum in item:
						raw_log_file.store_string(str(sequenceNum) + ", ")
					raw_log_file.store_string("], ")
				else:
					raw_log_file.store_string(str(item) + ", ")
			
			raw_log_file.store_string("\n")
		
		raw_log_file.close()

func write_sst_summary_log(datetime_dict):
	# open/create file
	var practice_str: String = ""
	if blocks[blocks_index] == block_type.PRACTICE:
		practice_str = "practice_"
	
	var summary_log_file_path: String = LevelManager.subject_name + "_target_digit_" + practice_str + "{year}-{month}-{day}-{hour}-{minute}-{second}_summary.txt".format(datetime_dict) # TODO let user choose dir
	# TODO add group and subject to file name
	var summary_log_file = FileAccess.open(summary_log_file_path, FileAccess.WRITE)
	print("summary log file created at " + summary_log_file_path + " with error code " + str(FileAccess.get_open_error()))
	
	if summary_log_file:
		# write date, time, subject, group, format guide
		summary_log_file.store_line("PsychologyFootball - Target Digit Test - Summary Data Log")
		summary_log_file.store_line("date: {day}-{month}-{year}".format(datetime_dict))
		summary_log_file.store_line("time: {hour}:{minute}:{second}".format(datetime_dict))
		summary_log_file.store_line("start date: {day}-{month}-{year}".format(start_datetime))
		summary_log_file.store_line("start time: {hour}:{minute}:{second}".format(start_datetime))
		summary_log_file.store_line("subject: " + LevelManager.subject_name) # TODO fill user-input subject and group
		summary_log_file.store_line("group: test")
		summary_log_file.store_string("\n-Final States of Counters-\n\n")
		
		# write counters
		summary_log_file.store_line("is_practice_block: " + str(blocks[blocks_index] == block_type.PRACTICE))
		summary_log_file.store_line("block_counter: " + str(block_counter))
		summary_log_file.store_line("trial_counter: " + str(trial_counter))
		summary_log_file.store_line("trials_passed: " + str(trials_passed))
		summary_log_file.store_line("span_length: " + str(span_length))
		
		# calculate probability of passing Trials
		var p_pt: float = float(trials_passed) / float(trial_counter) # successes / total
		
		## collect rolling totals for calculating means
		#var rolling_total_shift_reaction_time: int = 0
		#var rolling_total_non_shift_reaction_time: int = 0
		
		#for sub_array in metrics_array:
			#if sub_array[4] and sub_array[5]:
				## if shift trial passed
				#rolling_total_shift_reaction_time += sub_array[6]
			#if not sub_array[4] and sub_array[5]:
				## if non shift trial passed
				#rolling_total_non_shift_reaction_time += sub_array[6]
		
		## calculate mean reaction time (in ms) in Shift trials that were passed
		#var sr_rt = float(rolling_total_shift_reaction_time) / float(shift_trials_passed)
		#
		## calculate mean reaction time (in ms) in Non Shift trials that were passed
		#var nsr_rt = float(rolling_total_non_shift_reaction_time) / float(non_shift_trials_passed)
		
		# write summary data
		summary_log_file.store_string("\n-Calculated Summary Values-\n\n")
		summary_log_file.store_line("probability of passing Trials: " + str(p_pt))
		#summary_log_file.store_line("mean reaction time (in ms) in Shift trials that were passed: " + str(sr_rt))
		#summary_log_file.store_line("mean reaction time (in ms) in Non Shift trials that were passed: " + str(nsr_rt))
		
		summary_log_file.close()



