extends Sprite3D

@export var correct_sprite : Sprite3D
@export var wrong_sprite : Sprite3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Enter") && correct_sprite.visible == true:
		correct_sprite.visible = false
	else:
		if Input.is_action_just_pressed("Enter") && correct_sprite.visible == false:
			correct_sprite.visible = true
		
