extends Node3D

# spawnables
var ball_feeder_scene = preload("res://SubScenes/Ball_Feeder.tscn")
var defender_scene = preload("res://SubScenes/Defender.tscn")
var fixation_cone_scene = preload("res://SubScenes/Fixation_Cone.tscn")
var teammate_scene = preload("res://SubScenes/Teammate.tscn")

# time
const TICKS_BETWEEN_TRIALS_MSEC: int = 1000
const READY_TICKS_MSEC: int = 1000
const TRIAL_TICKS_MSEC: int = 2000
@onready var ticks_msec_bookmark: int = 0

# stop signal delay
const STOP_SIGNAL_DELAY_ADJUST_STEP: int = 50
const MAX_STOP_SIGNAL_DELAY: int = 1150
const MIN_STOP_SIGNAL_DELAY: int = STOP_SIGNAL_DELAY_ADJUST_STEP
var stop_signal_delay: int = 250

# blocks
enum block_type {TEST, PRACTICE}
## Array determines the order and type of blocks in the test.
@export var blocks: Array[block_type] = []
var blocks_index: int = 0

# counters
const GO_TRIALS_PER_PRACTICE_BLOCK: int = 3
const STOP_TRIALS_PER_PRACTICE_BLOCK: int = 1
const GO_TRIALS_PER_TEST_BLOCK: int = 75
const STOP_TRIALS_PER_TEST_BLOCK: int = 25

#var is_practice_block: bool = true
var go_trials_per_block: int = GO_TRIALS_PER_PRACTICE_BLOCK
var stop_trials_per_block: int = STOP_TRIALS_PER_PRACTICE_BLOCK
var block_counter: int = 0
var trial_counter: int = 0
var go_trial_counter: int = 0
var go_trials_passed: int = 0
var stop_trial_counter: int = 0
var stop_trials_passed: int = 0

# metrics
@onready var metrics_array = Array()
@onready var start_datetime = Time.get_datetime_dict_from_system()

# states
enum scene_state {WAIT, READY, GO_TRIAL, STOP_TRIAL}
# TODO create dict of states and corresponding func callables for defensive prog.
@onready var current_state = scene_state.WAIT

# signals
signal trial_started
signal trial_ended
signal stop_signal
signal ball_kicked
signal go_trial_failed
signal stop_trial_failed
@export var ball_kick_magnitude : float = 7

# flags
var is_feeder_left: bool = false
var is_trial_passed: bool = false
var has_responded: bool = false
var stop_signal_shown: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
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
				if stop_trial_counter >= stop_trials_per_block and go_trial_counter >= go_trials_per_block:
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
				
				# determine go or stop trial
				var is_stop: bool = (randf() < 0.25)
				if is_stop and stop_trial_counter < stop_trials_per_block:
					scene_trial_start(is_stop)
				elif (not is_stop) and go_trial_counter < go_trials_per_block:
					scene_trial_start(is_stop)
		
		
		scene_state.GO_TRIAL:
			if (Time.get_ticks_msec() - ticks_msec_bookmark) > TRIAL_TICKS_MSEC:
				# trial time is up
				
				if not is_trial_passed and not has_responded:
					go_trial_failed.emit()
					print("go_trial_failed")
					append_new_metrics_entry(false, is_trial_passed, 0)
				
				scene_reset()
			
			elif Input.is_action_just_pressed("kick_left") and not has_responded:
				has_responded = true
				if is_feeder_left:
					ball_kicked.emit($PlaceholderFixation.global_position, ball_kick_magnitude)
					is_trial_passed = true
					go_trials_passed += 1
					print("go_trial_passed")
				else:
					go_trial_failed.emit()
					print("go_trial_failed")
				append_new_metrics_entry(false, is_trial_passed, Time.get_ticks_msec() - ticks_msec_bookmark)
			
			elif Input.is_action_just_pressed("kick_right") and not has_responded:
				has_responded = true
				if not is_feeder_left: # is feeder right
					ball_kicked.emit($PlaceholderFixation.global_position, ball_kick_magnitude)
					is_trial_passed = true
					go_trials_passed += 1
					print("go_trial_passed")
				else:
					go_trial_failed.emit()
					print("go_trial_failed")
				append_new_metrics_entry(false, is_trial_passed, Time.get_ticks_msec() - ticks_msec_bookmark)
		
		
		scene_state.STOP_TRIAL:
			if (Time.get_ticks_msec() - ticks_msec_bookmark) > TRIAL_TICKS_MSEC:
				# trial time is up
				
				if is_trial_passed:
					stop_trials_passed += 1
					print("stop_trial_passed")
					append_new_metrics_entry(true, is_trial_passed, 0)
					
					if stop_signal_delay <= MAX_STOP_SIGNAL_DELAY - STOP_SIGNAL_DELAY_ADJUST_STEP:
						stop_signal_delay += STOP_SIGNAL_DELAY_ADJUST_STEP
						print("ssd adjusted up to " + str(stop_signal_delay))
				
				scene_reset()
			
			elif (Time.get_ticks_msec() - ticks_msec_bookmark) > stop_signal_delay and not stop_signal_shown:
				# time for stop signal
				stop_signal_shown = true
				
				stop_signal.emit()
				AudioManager.footsteps_sfx.play(0.0)
				AudioManager.footsteps_sfx.play(3.55)
			
			if (Input.is_action_just_pressed("kick_left") or Input.is_action_just_pressed("kick_right")) and not has_responded:
				has_responded = true
				is_trial_passed = false
				#ball_kicked.emit($PlaceholderFixation.global_position, ball_kick_magnitude)
				stop_trial_failed.emit()
				print("stop_trial_failed")
				append_new_metrics_entry(true, is_trial_passed, Time.get_ticks_msec() - ticks_msec_bookmark)
				
				if stop_signal_delay >= MIN_STOP_SIGNAL_DELAY + STOP_SIGNAL_DELAY_ADJUST_STEP:
					stop_signal_delay -= STOP_SIGNAL_DELAY_ADJUST_STEP
					print("ssd adjusted down to " + str(stop_signal_delay))

func scene_reset():
	print("scene_reset")
	
	AudioManager.footsteps_sfx.stop()
	
	# enable ball feeders
	#$PlaceholderBallFeederLeft/BallFeeder.process_mode = Node.PROCESS_MODE_ALWAYS
	#$PlaceholderBallFeederRight/BallFeeder.process_mode = Node.PROCESS_MODE_ALWAYS
	
	## remove left ball feeder ball
	#var left_ball = $PlaceholderBallFeederLeft/BallFeeder/BlueBall
	#if left_ball != null:
		#left_ball.free()
	#
	## remove right ball feeder ball
	#var right_ball = $PlaceholderBallFeederRight/BallFeeder/BlueBall
	#if right_ball != null:
		#right_ball.free()
	
	trial_ended.emit()
	
	# remove teammate
	if $PlaceholderFixation.get_child_count() != 0:
		$PlaceholderFixation/Teammate.free()
	
	# remove and respawn left defender
	if $PlaceholderDefenderLeft.get_child_count() != 0:
		$PlaceholderDefenderLeft/Defender.free()
		var new_defender_left = defender_scene.instantiate()
		$PlaceholderDefenderLeft.add_child(new_defender_left)
	
	# remove and respawn right defender
	if $PlaceholderDefenderRight.get_child_count() != 0:
		$PlaceholderDefenderRight/Defender.free()
		var new_defender_right = defender_scene.instantiate()
		$PlaceholderDefenderRight.add_child(new_defender_right)
	
	current_state = scene_state.WAIT
	ticks_msec_bookmark = Time.get_ticks_msec()

func scene_ready():
	print("scene_ready")
	
	# spawn fixation cone
	var new_fixation_cone = fixation_cone_scene.instantiate()
	$PlaceholderFixation.add_child(new_fixation_cone)
	
	current_state = scene_state.READY
	ticks_msec_bookmark = Time.get_ticks_msec()

func scene_trial_start(is_stop_trial: bool):
	# update trial counters
	trial_counter += 1
	if is_stop_trial:
		stop_trial_counter += 1
	else:
		go_trial_counter += 1
	
	print("scene_trial_start " + str(trial_counter) + ", is_stop_trial: " + str(is_stop_trial))
	
	# set up flags
	has_responded = false
	is_trial_passed = is_stop_trial
	stop_signal_shown = false
	if is_stop_trial:
		current_state = scene_state.STOP_TRIAL
	else:
		current_state = scene_state.GO_TRIAL
	
	# remove fixation cone
	if $PlaceholderFixation.get_child_count() != 0:
		$PlaceholderFixation/FixationCone.free()
	
	# spawn ball feeder, randomly choosing left or right side
	#var new_ball_feeder = ball_feeder_scene.instantiate()
	if randf() > 0.5:
		is_feeder_left = true
		#$PlaceholderBallFeederRight/BallFeeder.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		is_feeder_left = false
		#$PlaceholderBallFeederLeft/BallFeeder.process_mode = Node.PROCESS_MODE_DISABLED
	
	# spawn teammate
	var new_teammate = teammate_scene.instantiate()
	$PlaceholderFixation.add_child(new_teammate)
	
	# emit signal for ball feeder
	trial_started.emit(true, is_feeder_left)
	
	ticks_msec_bookmark = Time.get_ticks_msec()

#func stop_trial_start():
	## remove fixation cone
	#if $PlaceholderFixation.get_child_count() != 0:
		#$PlaceholderFixation/FixationCone.free()

func reset_counters():
	print("start STOP SIGNAL TASK block " + str(blocks_index + 1) + ". is_practice_block: " + str(blocks[blocks_index] == block_type.PRACTICE))
	
	if blocks[blocks_index] == block_type.PRACTICE:
		go_trials_per_block = GO_TRIALS_PER_PRACTICE_BLOCK
		stop_trials_per_block = STOP_TRIALS_PER_PRACTICE_BLOCK
	else:
		go_trials_per_block = GO_TRIALS_PER_TEST_BLOCK
		stop_trials_per_block = STOP_TRIALS_PER_TEST_BLOCK
	block_counter = 0
	trial_counter = 0
	go_trial_counter = 0
	go_trials_passed = 0
	stop_trial_counter = 0
	stop_trials_passed = 0

func append_new_metrics_entry(stop_trial: bool, correct_response: bool, response_time: int):
		metrics_array.append([block_counter, trial_counter, is_feeder_left, stop_trial, correct_response, response_time, stop_signal_delay])

func write_sst_raw_log(datetime_dict):
	# open/create file
	var practice_str: String = ""
	if blocks[blocks_index] == block_type.PRACTICE:
		practice_str = "practice_"
	
	var raw_log_file_path: String = LevelManager.subject_name + "_stop_signal_" + practice_str + "{year}-{month}-{day}-{hour}-{minute}-{second}_raw.txt".format(datetime_dict) # TODO let user choose dir
	var raw_log_file = FileAccess.open(raw_log_file_path, FileAccess.WRITE)
	print("raw log file created at " + raw_log_file_path + " with error code " + str(FileAccess.get_open_error()))
	
	# format guide
	# block_counter: int, trial_counter: int, stimulus_left: bool, stop_trial: bool,
	# correct_response: bool, response_time: int (ms), stop_signal_delay: int (ms)
	if raw_log_file:
		# write date, time, subject, group, format guide
		raw_log_file.store_line("PsychologyFootball - Stop Signal Test - Raw Data Log")
		raw_log_file.store_line("date: {day}-{month}-{year}".format(datetime_dict))
		raw_log_file.store_line("time: {hour}:{minute}:{second}".format(datetime_dict))
		raw_log_file.store_line("start date: {day}-{month}-{year}".format(start_datetime))
		raw_log_file.store_line("start time: {hour}:{minute}:{second}".format(start_datetime))
		raw_log_file.store_line("subject: " + LevelManager.subject_name)
		raw_log_file.store_line("group: test")# TODO fill user-input subject and group
		raw_log_file.store_string("\n-Format Guide-\n\nblock_counter, trial_counter, stimulus_left (ball feeder side), stop_trial, correct_response, response_time (ms), stop_signal_delay (ms)")
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
	
	var summary_log_file_path: String = LevelManager.subject_name + "_stop_signal_" + practice_str + "{year}-{month}-{day}-{hour}-{minute}-{second}_summary.txt".format(datetime_dict) # TODO let user choose dir
	var summary_log_file = FileAccess.open(summary_log_file_path, FileAccess.WRITE)
	print("summary log file created at " + summary_log_file_path + " with error code " + str(FileAccess.get_open_error()))
	
	if summary_log_file:
		# write date, time, subject, group, format guide
		summary_log_file.store_line("PsychologyFootball - Stop Signal Test - Summary Data Log")
		summary_log_file.store_line("date: {day}-{month}-{year}".format(datetime_dict))
		summary_log_file.store_line("time: {hour}:{minute}:{second}".format(datetime_dict))
		summary_log_file.store_line("start date: {day}-{month}-{year}".format(start_datetime))
		summary_log_file.store_line("start time: {hour}:{minute}:{second}".format(start_datetime))
		summary_log_file.store_line("subject: " + LevelManager.subject_name)
		summary_log_file.store_line("group: test")# TODO fill user-input subject and group
		summary_log_file.store_string("\n-Final States of Counters-\n\n")
		
		# write counters
		summary_log_file.store_line("is_practice_block: " + str(blocks[blocks_index] == block_type.PRACTICE))
		summary_log_file.store_line("go_trials_per_block: " + str(go_trials_per_block))
		summary_log_file.store_line("stop_trials_per_block: " + str(stop_trials_per_block))
		summary_log_file.store_line("block_counter: " + str(block_counter))
		summary_log_file.store_line("trial_counter: " + str(trial_counter))
		summary_log_file.store_line("go_trial_counter: " + str(go_trial_counter))
		summary_log_file.store_line("go_trials_passed: " + str(go_trials_passed))
		summary_log_file.store_line("stop_trial_counter: " + str(stop_trial_counter))
		summary_log_file.store_line("stop_trials_passed: " + str(stop_trials_passed))
		
		# calculate probability of reacting in Stop Signal Trials (prob(response|signal))
		var p_rs: float = float(stop_trial_counter - stop_trials_passed) / float(stop_trial_counter) # fails / total
		
		# collect rolling totals for calculating means
		var rolling_total_stop_signal_delay: int = 0
		var rolling_total_reaction_time: int = 0
		
		for sub_array in metrics_array:
			if sub_array[3]:
				# if stop signal
				rolling_total_stop_signal_delay += sub_array[6]
				rolling_total_reaction_time += sub_array[5]
		
		# calculate mean stop signal delays (in ms) in Stop Signal trials
		var ssd = float(rolling_total_stop_signal_delay) / float(stop_trial_counter)
		
		# calculate mean reaction time (in ms) in Stop Signal trials (response times of incorrectly hitting a response key)
		var sr_rt = float(rolling_total_reaction_time) / float(stop_trial_counter - stop_trials_passed) # (stops failed)
		
		# write summary data
		summary_log_file.store_string("\n-Calculated Summary Values-\n\n")
		summary_log_file.store_line("probability of reacting in Stop Signal Trials (prob(response|signal)), p_rs: " + str(p_rs))
		summary_log_file.store_line("mean stop signal delays (in ms) in Stop Signal trials, ssd: " + str(ssd))
		summary_log_file.store_line("mean reaction time (in ms) in Stop Signal trials (response times of incorrectly hitting a response key), sr_rt: " + str(sr_rt))
		
		summary_log_file.close()


