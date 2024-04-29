extends AnimatedSprite3D

@onready var anim = $"."

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play ("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
