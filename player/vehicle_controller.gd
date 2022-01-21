class_name PlayerVehicleController
extends Node

export(NodePath) var input_sink_path = null

onready var _input_sink = get_node(input_sink_path)


func _physics_process(delta: float) -> void:
	var steering_sensitivity = GlobalSettings.steering_sensitivity
	var return_speed = GlobalSettings.return_speed
	var throttle_sensitivity = GlobalSettings.throttle_sensitivity
	var brake_sensitivity = GlobalSettings.brake_sensitivity
	var steering_deadzone_inner = GlobalSettings.steering_deadzone_inner
	var steering_deadzone_outer = GlobalSettings.steering_deadzone_outer

	_input_sink.inputs.throttle = move_toward(
		_input_sink.inputs.throttle,
		Input.get_action_strength("throttle"),
		lerp(delta, 1, throttle_sensitivity)
	)
	_input_sink.inputs.clutch = Input.get_action_strength("clutch")
	_input_sink.inputs.brake = move_toward(
		_input_sink.inputs.brake,
		Input.get_action_strength("brake"),
		lerp(delta, 1, brake_sensitivity)
	)
	_input_sink.inputs.handbrake = Input.get_action_strength("handbrake")
	var steering_input = (
		Input.get_action_strength("steer_left")
		- Input.get_action_strength("steer_right")
	)

	if abs(steering_input) <= steering_deadzone_inner:
		steering_input = 0.0

	if abs(steering_input) >= (1 - steering_deadzone_outer):
		steering_input = 1.0 * sign(steering_input)

	if (
		abs(steering_input) > steering_deadzone_inner
		and abs(steering_input) < (1 - steering_deadzone_outer)
	):
		steering_input = (
			sign(steering_input)
			* inverse_lerp(
				steering_deadzone_inner, 1 - steering_deadzone_outer, abs(steering_input)
			)
		)

	var steering_factor = steering_sensitivity
	if abs(_input_sink.inputs.steering) > abs(steering_input):
		print("detected returning: %s, %s" % [steering_factor, return_speed])
		steering_factor *= return_speed
		print("updated turn speed: %s" % steering_factor)

	_input_sink.inputs.steering = move_toward(
		_input_sink.inputs.steering, steering_input, lerp(delta, 1, steering_factor)
	)
	if Input.is_action_just_pressed("gear_up"):
		_input_sink.inputs.gear_request = BuggedVehicle.GearRequest.UP
	elif Input.is_action_just_pressed("gear_down"):
		_input_sink.inputs.gear_request = BuggedVehicle.GearRequest.DOWN
	else:
		_input_sink.inputs.gear_request = BuggedVehicle.GearRequest.NONE
