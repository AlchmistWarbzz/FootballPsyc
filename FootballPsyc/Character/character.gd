extends Node3D


var red_team_mat = preload("res://Character/Mat/CharRed.tres")
var red_team_mat2 = preload("res://Character/Mat/CharDRed.tres")

@export var is_friendly: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_friendly:
		#$metarig/Skeleton3D/Mesh.set_material_override(blue_team_mat)
		pass
	else:
		#$metarig/Skeleton3D/Mesh.set_material_override(red_team_mat)
		$metarig/Skeleton3D/Mesh.set_surface_override_material(5, red_team_mat)
		$metarig/Skeleton3D/Mesh.set_surface_override_material(6, red_team_mat2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
