extends Node

@onready var football_touch_sfx: AudioStreamPlayer = $Football_Touch_SFX

@onready var ball_feeder_launch_sfx: AudioStreamPlayer = $Ball_Feeder_Launch_SFX

signal football_kick
signal football_touch
signal footsteps
signal ball_feeder_launch
signal stop_all_signalled_audio

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
