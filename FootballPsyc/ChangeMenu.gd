extends Node3D

var show_menu:bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	LevelManager.play_button_pressed.connect(hide_menu)
	$VirtualKeyboard.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if LevelManager.keyboard == true:
		show_keyboard()
		LevelManager.keyboard = false
	
func show_keyboard():
	$VirtualKeyboard.visible = true

func hide_menu():
	$Viewport2Din3D.visible = false
	#$Viewport2Din3D.queue_free()
	$VirtualKeyboard.visible = false
