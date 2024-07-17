extends Node3D

var xr_interface: XRInterface
var target #= $XROrigin3D/RightHand/FunctionPointer/RayCast.get_collider()
var left_trigger_pressed = false
var right_trigger_pressed = false
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





func _on_left_hand_button_pressed(name):
	#print("PRESSED LEFT TRIGGER")
	LevelManager.left_trigger.emit()
#
#
#func _on_right_hand_button_pressed(name):
	#print("PRESSED RIGHT TRIGGER")
	#target = $XROrigin3D/RightHand/FunctionPointer/RayCast.get_collider()
	#LevelManager.right_trigger.emit()
	#if target:
		##print("This is ", target.name)
		#LevelManager.current_target.emit(target)
	#else:
		#print("No target hit")


#func _on_function_pointer_pointing_event(event):
	#target = $XROrigin3D/RightHand/FunctionPointer/RayCast.get_collider()
	#if target:
		#print("This is ", target.name)
	#else:
		#print("No target hit")
	


func _on_right_hand_input_float_changed(name, value):
	if LevelManager.in_task == true:
		if value == 1 and not left_trigger_pressed:
			#print("PRESSED RIGHT TRIGGER")
			right_trigger_pressed = true
			print("Right is", name)
			target = $XROrigin3D/RightHand/FunctionPointer/RayCast.get_collider()
			LevelManager.right_trigger.emit()
			if target:
				#print("This is ", target.name)
				LevelManager.current_target.emit(target)
			else:
				print("No target hit")
		elif value != 1:
			right_trigger_pressed = false


func _on_left_hand_input_float_changed(name, value):
	#rint("This is the float", value)
	if LevelManager.in_task == true:
		# Check if the value equals 1 and the trigger has not been pressed yet
		if value == 1 and not right_trigger_pressed:
			print("LEFT TRIGGER")
			left_trigger_pressed = true
			LevelManager.left_trigger.emit()
			target = $XROrigin3D/LeftHand/FunctionPointer/RayCast.get_collider()
			if target:
				#print("This is ", target.name)
				LevelManager.current_target.emit(target)
			else:
				print("No target hit")

		elif value != 1:
			left_trigger_pressed = false
