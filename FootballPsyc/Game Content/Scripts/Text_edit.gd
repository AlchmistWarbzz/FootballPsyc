extends LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
#
#func _on_text_submitted(text):
	#print("Submitted text:", text)
	#var trial_length_int = int(text)
	#print("Parsed integer:", trial_length_int)
	#LevelManager.trial_length = text
	#print("LevelManager.trial_length:", LevelManager.trial_length)




func _on_text_changed(text):
	print("Submitted text:", text)
	#var trial_length_int = int(text)
	#print("Parsed integer:", trial_length_int)
	#LevelManager.trial_length = text
	LevelManager.subject_name = text
	print("LevelManager.subject_name:", LevelManager.subject_name)
