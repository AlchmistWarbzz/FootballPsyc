extends Sprite3D

@export var correct_sprite: Sprite3D
@export var wrong_sprite: Sprite3D
@export var show_ticks_msec: int = 1000

# time
@onready var ticks_msec_bookmark: int = 0

# states
enum feedback_state {NEUTRAL, CORRECT, WRONG}
@onready var current_state: feedback_state = feedback_state.NEUTRAL


# Called when the node enters the scene tree for the first time.
func _ready():
	hide_sprites()
	
	LevelManager.trial_ended.connect(_on_trial_ended)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# TEST INPUTS
	#if Input.is_action_just_pressed("Enter") && correct_sprite.visible == true:
		#correct_sprite.visible = false
	#else:
		#if Input.is_action_just_pressed("Enter") && correct_sprite.visible == false:
			#correct_sprite.visible = true
	if Input.is_action_just_pressed("ui_left"):
		show_sprite(true)
	elif Input.is_action_just_pressed("ui_right"):
		show_sprite(false)
	
	match current_state:
		feedback_state.NEUTRAL:
			hide_sprites()
		
		feedback_state.CORRECT:
			if (Time.get_ticks_msec() - ticks_msec_bookmark) > show_ticks_msec:
				# show time is finished
				hide_sprites()
			else:
				correct_sprite.visible = true
		
		feedback_state.WRONG:
			if (Time.get_ticks_msec() - ticks_msec_bookmark) > show_ticks_msec:
				# show time is finished
				hide_sprites()
			else:
				wrong_sprite.visible = true


func _on_trial_ended(correct: bool) -> void:
	show_sprite(correct)


func hide_sprites() -> void:
	correct_sprite.visible = false
	wrong_sprite.visible = false
	
	current_state = feedback_state.NEUTRAL


func start_show_timer() -> void:
	ticks_msec_bookmark = Time.get_ticks_msec()


func show_sprite(correct: bool) -> void:
	if (correct):
		current_state = feedback_state.CORRECT
	else:
		current_state = feedback_state.WRONG
	
	start_show_timer()

