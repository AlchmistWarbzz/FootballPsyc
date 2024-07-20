extends Node3D

var xr_interface: XRInterface
var target #= $XROrigin3D/RightHand/FunctionPointer/RayCast.get_collider()
var left_trigger_pressed = false
var right_trigger_pressed = false
var left_raycast
var right_raycast


var right_laser
var left_laser


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
	right_laser = $XROrigin3D/RightHand/FunctionPointer
	left_laser = $XROrigin3D/LeftHand/FunctionPointer
	LevelManager.show_laser.connect(_show_laser)


func _on_right_hand_input_float_changed(name, value):
	if LevelManager.in_task == true:
		if value > 0.5 and not left_trigger_pressed:
			#print("PRESSED RIGHT TRIGGER")
			right_trigger_pressed = true
			#print("Right is", name)
			target = $XROrigin3D/RightHand/FunctionPointer/RayCast.get_collider() 
			LevelManager.right_trigger.emit()
			if target:
				print("This is ", target.name)
				LevelManager.current_target.emit(target)
			else:
				#print("No target hit")
				pass
		elif value != 1:
			right_trigger_pressed = false
	#print(right_laser.show_laser)


func _on_left_hand_input_float_changed(name, value):
	#rint("This is the float", value)
	if LevelManager.in_task == true:
		# Check if the value equals 1 and the trigger has not been pressed yet
		if value > 0.5 and not right_trigger_pressed:
			#print("LEFT TRIGGER")
			left_trigger_pressed = true
			LevelManager.left_trigger.emit()
			target = $XROrigin3D/LeftHand/FunctionPointer/RayCast.get_collider()
			#print("This is ", target.name)
			if target:
				print("This is ", target.name)
				LevelManager.current_target.emit(target)
			else:
				#print("No target hit")
				pass
		elif value != 1:
			left_trigger_pressed = false

func _show_laser():
	if LevelManager.bds_task == true:
		left_laser.show_laser = 1
		right_laser.show_laser = 1
		left_laser.show_target = true
		right_laser.show_target = true
	else:
		left_laser.show_laser = 2
		right_laser.show_laser = 2
		left_laser.show_target = true
		right_laser.show_target = true
		


