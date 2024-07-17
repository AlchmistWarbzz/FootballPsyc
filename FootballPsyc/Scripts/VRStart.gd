extends Node3D

var xr_interface: XRInterface
var target #= $XROrigin3D/RightHand/FunctionPointer/RayCast.get_collider()


func _ready():
	#$"/root/GameController".registerplayer(self)
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")
		#Global.load_game.emit()

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected")


#func getposition():
		#return self.global.transform.origin


func _on_left_hand_button_pressed(name):
	#print("PRESSED LEFT TRIGGER")
	LevelManager.left_trigger.emit()


func _on_right_hand_button_pressed(name):
	#print("PRESSED RIGHT TRIGGER")
	target = $XROrigin3D/RightHand/FunctionPointer/RayCast.get_collider()
	LevelManager.right_trigger.emit()
	if target:
		#print("This is ", target.name)
		LevelManager.current_target.emit(target)
	else:
		print("No target hit")


#func _on_function_pointer_pointing_event(event):
	#target = $XROrigin3D/RightHand/FunctionPointer/RayCast.get_collider()
	#if target:
		#print("This is ", target.name)
	#else:
		#print("No target hit")
	#
