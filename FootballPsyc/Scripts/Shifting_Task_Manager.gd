extends Node3D

# spawnables
const BALL_FEEDER_SCENE = preload("res://SubScenes/Ball_Feeder.tscn")
const FIXATION_CONE = preload("res://SubScenes/Fixation_Cone.tscn")

# time
const TICKS_BETWEEN_TRIALS_MSEC: int = 1000
const READY_TICKS_MSEC: int = 1000
const TRIAL_TICKS_MSEC: int = 2000
@onready var ticks_msec_bookmark: int = 0

# blocks
enum block_type {TEST, PRACTICE}
## Array determines the order and type of blocks in the test.
@export var blocks: Array[block_type] = []
var blocks_index: int = 0

# counters
const SHIFT_TRIALS_PER_PRACTICE_BLOCK: int = 1
const NON_SHIFT_TRIALS_PER_PRACTICE_BLOCK: int = 3
const SHIFT_TRIALS_PER_TEST_BLOCK: int = 12
const NON_SHIFT_TRIALS_PER_TEST_BLOCK: int = 36

#var is_practice_block: bool = true
var shift_trials_per_block: int = SHIFT_TRIALS_PER_PRACTICE_BLOCK
var non_shift_trials_per_block: int = NON_SHIFT_TRIALS_PER_PRACTICE_BLOCK
var block_counter: int = 0
var trial_counter: int = 0
var shift_trial_counter: int = 0
var shift_trials_passed: int = 0
var non_shift_trial_counter: int = 0
var non_shift_trials_passed: int = 0

# metrics
@onready var metrics_array = Array()
@onready var start_datetime = Time.get_datetime_dict_from_system()

# states
enum scene_state {WAIT, READY, TRIAL}
# TODO create dict of states and corresponding func callables for defensive prog.
@onready var current_state = scene_state.WAIT

# signals
signal trial_started
signal trial_ended
signal ball_kicked
@export var ball_kick_magnitude : float = 7

# flags
var is_feeder_left: bool = false
var is_trial_passed: bool = false
var is_blue_ball: bool = false
var is_shift_trial: bool = false
var has_responded: bool = false


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
			if (Time.get_ticks_msec() - ticks_msec_bookmark) > TICKS_BETWEEN_TRIALS_MSEC:
				# wait time is up
				
				# check block finished
				if shift_trial_counter >= shift_trials_per_block and non_shift_trial_counter >= non_shift_trials_per_block:
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
			if (Time.get_ticks_msec() - ticks_msec_bookmark) > READY_TICKS_MSEC:
				# ready time is up
				
				# determine shift or non shift trial
				var rand_is_shift : bool = (randf() < 0.25)
				if rand_is_shift and shift_trial_counter < shift_trials_per_block:
					is_shift_trial = true
					scene_trial_start()
				elif (not rand_is_shift) and non_shift_trial_counter < non_shift_trials_per_block:
					is_shift_trial = false
					scene_trial_start()
		
		
		scene_state.TRIAL:
			if (Time.get_ticks_msec() - ticks_msec_bookmark) > TRIAL_TICKS_MSEC:
				# trial time is up
				
				if not is_trial_passed and not has_responded:
					#go_trial_failed.emit()
					print("non_shift_trial_failed")
					append_new_metrics_entry(0)
				
				scene_reset()
				
				current_state = scene_state.WAIT
				ticks_msec_bookmark = Time.get_ticks_msec()
			
			elif Input.is_action_just_pressed("kick_left") and not has_responded:
				has_responded = true
				if check_correct_kick(true): # is kick left
					ball_kicked.emit($MiniGoalLeft.global_position, ball_kick_magnitude)
					is_trial_passed = true
					
					if is_shift_trial:
						shift_trials_passed += 1
						print("shift_trial_passed")
					else:
						non_shift_trials_passed += 1
						print("non_shift_trial_passed")
				else:
					#go_trial_failed.emit()
					print("non_shift_trial_failed")
				append_new_metrics_entry(Time.get_ticks_msec() - ticks_msec_bookmark)
			
			elif Input.is_action_just_pressed("kick_right") and not has_responded:
				has_responded = true
				if check_correct_kick(false): # is kick right
					ball_kicked.emit($MiniGoalRight.global_position, ball_kick_magnitude)
					is_trial_passed = true
					
					if is_shift_trial:
						shift_trials_passed += 1
						print("shift_trial_passed")
					else:
						non_shift_trials_passed += 1
						print("non_shift_trial_passed")
				else:
					#go_trial_failed.emit()
					if is_shift_trial:
						print("shift_trial_failed")
					else:
						print("non_shift_trial_failed")
				append_new_metrics_entry(Time.get_ticks_msec() - ticks_msec_bookmark)

func scene_reset():
	print("scene_reset")
	
	trial_ended.emit()
	
	current_state = scene_state.WAIT
	ticks_msec_bookmark = Time.get_ticks_msec()

func scene_ready():
	print("scene_ready")
	
	# spawn fixation cone
	var new_fixation_cone = FIXATION_CONE.instantiate()
	$PlaceholderFixation.add_child(new_fixation_cone)
	
	current_state = scene_state.READY
	ticks_msec_bookmark = Time.get_ticks_msec()

func scene_trial_start():
	# update trial counters
	trial_counter += 1
	if is_shift_trial:
		shift_trial_counter += 1
	else:
		non_shift_trial_counter += 1
		
	print("scene_trial_start " + str(trial_counter) + ", is_shift_trial: " + str(is_shift_trial))
	
	# remove fixation cone
	if $PlaceholderFixation.get_child_count() != 0:
		$PlaceholderFixation/FixationCone.free()
	
	# set up flags
	has_responded = false
	is_trial_passed = false
	
	# determine ball colour
	if is_shift_trial:
		is_blue_ball = not is_blue_ball
	
	# randomly choosing left or right ball feeder
	if randf() > 0.5:
		is_feeder_left = true
		trial_started.emit(is_blue_ball, is_feeder_left)
	else:
		is_feeder_left = false
		trial_started.emit(is_blue_ball, is_feeder_left)
	
	current_state = scene_state.TRIAL
	ticks_msec_bookmark = Time.get_ticks_msec()

func reset_counters():
	print("start COLOUR BALL TEST block " + str(blocks_index + 1) + ". is_practice_block: " + str(blocks[blocks_index] == block_type.PRACTICE))
	
	if blocks[blocks_index] == block_type.PRACTICE:
		shift_trials_per_block = SHIFT_TRIALS_PER_PRACTICE_BLOCK
		non_shift_trials_per_block = NON_SHIFT_TRIALS_PER_PRACTICE_BLOCK
	else:
		shift_trials_per_block = SHIFT_TRIALS_PER_TEST_BLOCK
		non_shift_trials_per_block = NON_SHIFT_TRIALS_PER_TEST_BLOCK
	block_counter = 0
	trial_counter = 0
	shift_trial_counter = 0
	shift_trials_passed = 0
	non_shift_trial_counter = 0
	non_shift_trials_passed = 0

func check_correct_kick(is_kick_left: bool) -> bool:
	if is_kick_left:
		if is_feeder_left:
			return not is_blue_ball
		else:
			return is_blue_ball
	else:
		if is_feeder_left:
			return is_blue_ball
		else:
			return not is_blue_ball

func append_new_metrics_entry(response_time: int):
	metrics_array.append([block_counter, trial_counter, is_feeder_left, is_blue_ball, is_shift_trial, is_trial_passed, response_time])

func write_sst_raw_log(datetime_dict):
	# open/create file
	var practice_str: String = ""
	if blocks[blocks_index] == block_type.PRACTICE:
		practice_str = "practice_"
	
	var raw_log_file_path: String = LevelManager.subject_name + "_colour_ball_" + practice_str + "{year}-{month}-{day}-{hour}-{minute}-{second}_raw.txt".format(datetime_dict) # TODO let user choose dir
	var raw_log_file = FileAccess.open(raw_log_file_path, FileAccess.WRITE)
	print("raw log file created at " + raw_log_file_path + " with error code " + str(FileAccess.get_open_error()))
	
	# format guide
	# block_counter: int, trial_counter: int, stimulus_left: bool, stop_trial: bool,
	# correct_response: bool, response_time: int (ms), stop_signal_delay: int (ms)
	if raw_log_file:
		# write date, time, subject, group, format guide
		raw_log_file.store_line("PsychologyFootball - Colour Ball Test - Raw Data Log")
		raw_log_file.store_line("date: {day}-{month}-{year}".format(datetime_dict))
		raw_log_file.store_line("time: {hour}:{minute}:{second}".format(datetime_dict))
		raw_log_file.store_line("start date: {day}-{month}-{year}".format(start_datetime))
		raw_log_file.store_line("start time: {hour}:{minute}:{second}".format(start_datetime))
		raw_log_file.store_line("subject: " + LevelManager.subject_name) # TODO fill user-input subject and group
		raw_log_file.store_line("group: test")
		raw_log_file.store_string("\n-Format Guide-\n\nblock_counter, trial_counter, stimulus_left (ball feeder side), is_blue_ball, is_shift_trial, correct_response, response_time (ms)")
		raw_log_file.store_string("\n\n-Raw Data-\n\n")
		
		for sub_array in metrics_array:
			var line = "{0}, {1}, {2}, {3}, {4}, {5}, {6}"
			raw_log_file.store_line(line.format(sub_array))
		
		raw_log_file.close()

func write_sst_summary_log(datetime_dict):
	# open/create file
	var practice_str: String = ""
	if blocks[blocks_index] == block_type.PRACTICE:
		practice_str = "practice_"
	
	var summary_log_file_path: String = LevelManager.subject_name + "_colour_ball_" + practice_str + "{year}-{month}-{day}-{hour}-{minute}-{second}_summary.txt".format(datetime_dict) # TODO let user choose dir
	var summary_log_file = FileAccess.open(summary_log_file_path, FileAccess.WRITE)
	print("summary log file created at " + summary_log_file_path + " with error code " + str(FileAccess.get_open_error()))
	
	if summary_log_file:
		# write date, time, subject, group, format guide
		summary_log_file.store_line("PsychologyFootball - Colour Ball Test - Summary Data Log")
		summary_log_file.store_line("date: {day}-{month}-{year}".format(datetime_dict))
		summary_log_file.store_line("time: {hour}:{minute}:{second}".format(datetime_dict))
		summary_log_file.store_line("start date: {day}-{month}-{year}".format(start_datetime))
		summary_log_file.store_line("start time: {hour}:{minute}:{second}".format(start_datetime))
		summary_log_file.store_line("subject: " + LevelManager.subject_name) # TODO fill user-input subject and group
		summary_log_file.store_line("group: test")
		summary_log_file.store_string("\n-Final States of Counters-\n\n")
		
		# write counters
		summary_log_file.store_line("is_practice_block: " + str(blocks[blocks_index] == block_type.PRACTICE))
		summary_log_file.store_line("non_shift_trials_per_block: " + str(non_shift_trials_per_block))
		summary_log_file.store_line("shift_trials_per_block: " + str(shift_trials_per_block))
		summary_log_file.store_line("block_counter: " + str(block_counter))
		summary_log_file.store_line("trial_counter: " + str(trial_counter))
		summary_log_file.store_line("non_shift_trial_counter: " + str(non_shift_trial_counter))
		summary_log_file.store_line("non_shift_trials_passed: " + str(non_shift_trials_passed))
		summary_log_file.store_line("shift_trial_counter: " + str(shift_trial_counter))
		summary_log_file.store_line("shift_trials_passed: " + str(shift_trials_passed))
		
		# calculate probability of passing Shift Trials
		var p_rs: float = float(shift_trials_passed) / float(shift_trial_counter) # successes / total
		
		# collect rolling totals for calculating means
		var rolling_total_shift_reaction_time: int = 0
		var rolling_total_non_shift_reaction_time: int = 0
		
		for sub_array in metrics_array:
			if sub_array[4] and sub_array[5]:
				# if shift trial passed
				rolling_total_shift_reaction_time += sub_array[6]
			if not sub_array[4] and sub_array[5]:
				# if non shift trial passed
				rolling_total_non_shift_reaction_time += sub_array[6]
		
		# calculate mean reaction time (in ms) in Shift trials that were passed
		var sr_rt = float(rolling_total_shift_reaction_time) / float(shift_trials_passed)
		
		# calculate mean reaction time (in ms) in Non Shift trials that were passed
		var nsr_rt = float(rolling_total_non_shift_reaction_time) / float(non_shift_trials_passed)
		
		# write summary data
		summary_log_file.store_string("\n-Calculated Summary Values-\n\n")
		summary_log_file.store_line("probability of passing Shift Trials: " + str(p_rs))
		summary_log_file.store_line("mean reaction time (in ms) in Shift trials that were passed: " + str(sr_rt))
		summary_log_file.store_line("mean reaction time (in ms) in Non Shift trials that were passed: " + str(nsr_rt))
		
		summary_log_file.close()



