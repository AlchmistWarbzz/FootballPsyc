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
	match LevelManager.task_to_load_UI:
		1:
			#image_to_set = sst_rules_image
			$"Colour Shift".visible = false
			$"Digit Span".visible = false
		2:
			#image_to_set = shifting_rules_image
			$"Stop & Go".visible = false
			$"Digit Span".visible = false
		3:
			#image_to_set = bds_rules_image
			$"Stop & Go".visible = false
			$"Colour Shift".visible = false
	
	#print(str(LevelManager.task_to_load_UI) + " from go trial rules")
	
	#$"Stop & Go".texture = $"Stop & Go".load(image_to_set)
	#print(str($"Stop & Go".get_texture()))
	
	
	#await get_tree().create_timer(10.0).timeout
	#deactivate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func deactivate() -> void:
	hide()
	#set_process_unhandled_input(false)
	#set_process_input(false)
	#set_physics_process(false)
	#set_process(false)


func _on_play_button_pressed() -> void:
	deactivate()
	LevelManager.play_button_pressed.emit()
