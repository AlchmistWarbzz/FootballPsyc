extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass




func _on_button_pressed():
	deactivate()
	LevelManager.load_level(1, 1)

func _on_button_2_pressed() -> void:
	deactivate()
	LevelManager.load_level(1, 2)

func _on_button_3_pressed() -> void:
	deactivate()
	LevelManager.load_level(1, 3)

func deactivate() -> void:
	hide()
	#set_process_unhandled_input(false)
	#set_process_input(false)
	#set_physics_process(false)
	#set_process(false)






