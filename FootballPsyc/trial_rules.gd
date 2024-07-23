extends Control

#var sst_rules_image : Texture2D = preload("res://UI/How To Play/Rules.png")
#var shifting_rules_image : Texture2D = preload("res://UI/How To Play/Colour Shifting.png")
#var bds_rules_image : Texture2D = preload("res://UI/How To Play/BDS Test.png")
#var sst_rules_image = "res://UI/How To Play/Rules.png"
#var shifting_rules_image = "res://UI/How To Play/Colour Shifting.png"
#var bds_rules_image = "res://UI/How To Play/BDS Test.png"


# Called when the node enters the scene tree for the first time.
func _ready():
	#var image_to_set
	show_hide_task_rules()
	
	#print(str(LevelManager.task_to_load_UI) + " from go trial rules")
	
	#$"Stop & Go".texture = $"Stop & Go".load(image_to_set)
	#print(str($"Stop & Go".get_texture()))
	
	
	#await get_tree().create_timer(10.0).timeout
	#deactivate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func deactivate() -> void:
	#hide()
	$LineEditSubject.queue_free()
	$LineEditGroup.queue_free()
	$PlayButton.queue_free()
	#set_process_unhandled_input(false)
	#set_process_input(false)
	#set_physics_process(false)
	#set_process(false)


func _on_play_button_pressed() -> void:
	deactivate()
	LevelManager.play_button_pressed.emit()


func show_hide_task_rules() -> void:
	match LevelManager.task_to_load:
		1:
			#image_to_set = sst_rules_image
			#$stop_go.visible = true
			#$colour_shift.visible = false
			#$digit_span.visible = false
			$Rules.texture = load("res://.godot/imported/StopSignal.jpg-de2ee8ac209c696c89e6c36678b2b421.ctex")
		2:
			#image_to_set = shifting_rules_image
			#$stop_go.visible = false
			#$colour_shift.visible = true
			#$digit_span.visible = false
			$Rules.texture = load("res://.godot/imported/ColourBall.jpg-23e4eed9f8eb7b34f193245e93a5a803.ctex")
		3:
			#image_to_set = bds_rules_image
			#$stop_go.visible = false
			#$colour_shift.visible = false
			#$digit_span.visible = true
			$Rules.texture =load("res://.godot/imported/BackwardsDigitTest.jpg-79e1d376a575b6167f85a45c66a06f0e.ctex")


func _on_visibility_changed() -> void:
	show_hide_task_rules()


func _on_button_pressed():
	LevelManager.return_button_pressed.emit()
	LevelManager.leave_trial.emit()
	LevelManager.bds_task = false
	LevelManager.show_laser.emit()
