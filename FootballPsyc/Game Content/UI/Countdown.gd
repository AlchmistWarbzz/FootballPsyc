extends Control

var three
var two
var one
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	##if Global.countdown == true:
		three.visible = true
		two.visible = false
		one.visible = false
		await get_tree().create_timer(1).timeout
		three.visible = false
		two.visible = true
		one.visible = false
		await get_tree().create_timer(.9).timeout
		three.visible = false
		two.visible = false
		one.visible = true
		await get_tree().create_timer(.85).timeout
		three.visible = false
		two.visible = false
		one.visible = false
		
