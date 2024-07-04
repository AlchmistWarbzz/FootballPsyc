extends Node

@onready var node_3d = $Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelManager.main_scene = node_3d
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

