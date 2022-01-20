class_name PlayerVehicleController
extends Node

export(NodePath) var vehicle_path = null

onready var _vehicle: BuggedVehicle = get_node(vehicle_path)


func _input(_event: InputEvent) -> void:
	# Using _input just to make sure events are captured right away
	_vehicle.inputs.throttle = Input.get_action_strength("throttle")
	_vehicle.inputs.clutch = Input.get_action_strength("clutch")
	_vehicle.inputs.brake = Input.get_action_strength("brake")
	_vehicle.inputs.handbrake = Input.get_action_strength("handbrake")
	var steering_input = (
		Input.get_action_strength("steer_left")
		- Input.get_action_strength("steer_right")
	)
	# TODO: deadzone config
	if abs(steering_input) < 0.05:
		steering_input = 0.0
	_vehicle.inputs.steering = steering_input
	if Input.is_action_just_pressed("gear_up"):
		_vehicle.inputs.gear_request = BuggedVehicle.GearRequest.UP
	elif Input.is_action_pressed("gear_down"):
		_vehicle.inputs.gear_request = BuggedVehicle.GearRequest.DOWN
	else:
		_vehicle.inputs.gear_request = BuggedVehicle.GearRequest.NONE
