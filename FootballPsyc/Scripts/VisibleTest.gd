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
	correct_sprite.visible = false
	wrong_sprite.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if Input.is_action_just_pressed("Enter") && correct_sprite.visible == true:
		#correct_sprite.visible = false
	#else:
		#if Input.is_action_just_pressed("Enter") && correct_sprite.visible == false:
			#correct_sprite.visible = true
	if Input.is_action_just_pressed("ui_left"):
		current_state = feedback_state.CORRECT
		start_show_timer()
	elif Input.is_action_just_pressed("ui_right"):
		current_state = feedback_state.WRONG
		start_show_timer()
	
	match current_state:
		feedback_state.NEUTRAL:
			hide_sprites()
		
		feedback_state.CORRECT:
			if (Time.get_ticks_msec() - ticks_msec_bookmark) > show_ticks_msec:
				# show time is finished
				hide_sprites()
				current_state = feedback_state.NEUTRAL
			else:
				correct_sprite.visible = true
		
		feedback_state.WRONG:
			if (Time.get_ticks_msec() - ticks_msec_bookmark) > show_ticks_msec:
				# show time is finished
				hide_sprites()
				current_state = feedback_state.NEUTRAL
			else:
				wrong_sprite.visible = true


func hide_sprites() -> void:
	correct_sprite.visible = false
	wrong_sprite.visible = false


func start_show_timer() -> void:
	ticks_msec_bookmark = Time.get_ticks_msec()

