extends Node


@onready var anim = $"."


# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("GoTrial")




