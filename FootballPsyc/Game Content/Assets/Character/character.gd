extends Node3D

var blue_team_mat = preload("res://Character/Blue_Mat.tres")
var red_team_mat = preload("res://Character/Red_Mat.tres")

@export var is_friendly: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_friendly:
		$metarig/Skeleton3D/Sphere_005.set_material_override(blue_team_mat)
	else:
		$metarig/Skeleton3D/Sphere_005.set_material_override(red_team_mat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
